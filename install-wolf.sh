#!/bin/bash

set -euo pipefail

NAMESPACE="wolf"
WOLF_CONFIG_DIR="/etc/wolf"
WOLF_IMAGE="ghcr.io/games-on-whales/wolf:stable"
PODMAN_SIDECAR_IMAGE="quay.io/podman/stable:latest"

export KUBECONFIG="${KUBECONFIG:-/etc/rancher/k3s/k3s.yaml}"

if ! kubectl get nodes &>/dev/null; then
    echo "Cannot reach k3s API server"
    exit 1
fi

if ! ls /dev/dri/renderD* &>/dev/null; then
    echo "Warning: no /dev/dri/renderD* found"
fi

sudo mkdir -p "$WOLF_CONFIG_DIR"

kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

kubectl delete deployment wolf -n "$NAMESPACE" --ignore-not-found
kubectl delete service wolf -n "$NAMESPACE" --ignore-not-found
kubectl wait --for=delete pod -l app=wolf -n "$NAMESPACE" --timeout=30s 2>/dev/null || true

kubectl apply -f - <<EOF
---
apiVersion: v1
kind: Service
metadata:
  name: wolf
  namespace: ${NAMESPACE}
spec:
  selector:
    app: wolf
  type: NodePort
  ports:
    - name: rtsp
      protocol: TCP
      port: 47984
      targetPort: 47984
      nodePort: 47984
    - name: https-stream
      protocol: TCP
      port: 47989
      targetPort: 47989
      nodePort: 47989
    - name: video
      protocol: TCP
      port: 48010
      targetPort: 48010
      nodePort: 48010
    - name: pulseaudio
      protocol: TCP
      port: 4713
      targetPort: 4713
      nodePort: 34713
    - name: control
      protocol: UDP
      port: 47999
      targetPort: 47999
      nodePort: 47999
    - name: audio
      protocol: UDP
      port: 48100
      targetPort: 48100
      nodePort: 48100
    - name: mic
      protocol: UDP
      port: 48200
      targetPort: 48200
      nodePort: 48200
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: wolf
  namespace: ${NAMESPACE}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: wolf
  template:
    metadata:
      labels:
        app: wolf
    spec:
      initContainers:
        - name: socket-dir-init
          image: busybox:stable
          command: ["sh", "-c", "mkdir -p /podman-sock && chmod 777 /podman-sock"]
          volumeMounts:
            - name: podman-socket-dir
              mountPath: /podman-sock

      containers:
        - name: podman-sidecar
          image: ${PODMAN_SIDECAR_IMAGE}
          command:
            - sh
            - -c
            - |
              echo "Starting podman service..."
              podman system service --time=0 unix:///podman-sock/docker.sock --log-level=debug
          securityContext:
            privileged: true
            runAsUser: 0
          volumeMounts:
            - name: podman-socket-dir
              mountPath: /podman-sock
            - name: wolf-config
              mountPath: /etc/wolf
            - name: dev-dri
              mountPath: /dev/dri
            - name: dev-uinput
              mountPath: /dev/uinput
            - name: udev-run
              mountPath: /run/udev
              readOnly: true
            - name: podman-storage
              mountPath: /var/lib/containers

        - name: wolf
          image: ${WOLF_IMAGE}
          securityContext:
            privileged: true
            runAsUser: 0
          env:
            - name: DOCKER_HOST
              value: "unix:///podman-sock/docker.sock"
          command:
            - sh
            - -c
            - |
              echo "Waiting for podman socket..."
              until [ -S /podman-sock/docker.sock ]; do
                sleep 1
              done

              echo "Podman socket is ready, starting Wolf..."
              exec /entrypoint.sh
          ports:
            - containerPort: 47984
              protocol: TCP
            - containerPort: 47989
              protocol: TCP
            - containerPort: 48010
              protocol: TCP
            - containerPort: 4713
              protocol: TCP
            - containerPort: 47999
              protocol: UDP
            - containerPort: 48100
              protocol: UDP
            - containerPort: 48200
              protocol: UDP
          volumeMounts:
            - name: wolf-config
              mountPath: /etc/wolf
            - name: podman-socket-dir
              mountPath: /podman-sock
            - name: dev-dri
              mountPath: /dev/dri
            - name: dev-uinput
              mountPath: /dev/uinput
            - name: dev-uhid
              mountPath: /dev/uhid
            - name: udev-run
              mountPath: /run/udev
              readOnly: true

      volumes:
        - name: podman-socket-dir
          emptyDir: {}
        - name: wolf-config
          hostPath:
            path: ${WOLF_CONFIG_DIR}
            type: DirectoryOrCreate
        - name: dev-dri
          hostPath:
            path: /dev/dri
            type: Directory
        - name: dev-uinput
          hostPath:
            path: /dev/uinput
            type: CharDevice
        - name: dev-uhid
          hostPath:
            path: /dev/uhid
            type: CharDevice
        - name: udev-run
          hostPath:
            path: /run/udev
            type: Directory
        - name: podman-storage
          hostPath:
            path: /var/lib/wolf-podman
            type: DirectoryOrCreate
EOF

kubectl rollout status deployment/wolf -n "$NAMESPACE" --timeout=120s

kubectl get pods -n "$NAMESPACE" -l app=wolf -o wide
kubectl get svc wolf -n "$NAMESPACE"