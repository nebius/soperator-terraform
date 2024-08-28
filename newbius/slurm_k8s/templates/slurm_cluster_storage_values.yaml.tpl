scheduling:
  cpuOnly:
    matchExpressions:
      - key: kubernetes.io/hostname
        operator: In
        values:
          - "computeinstance-placeholder-cpu-1"
          - "computeinstance-placeholder-cpu-2"
    tolerations:
      - key: slurm.nebius.ai/taint
        operator: Equal
        value: cpu
        effect: NoSchedule
  cpuAndGpu:
    matchExpressions:
      - key: kubernetes.io/hostname
        operator: In
        values:
          - "computeinstance-placeholder-cpu-1"
          - "computeinstance-placeholder-cpu-2"
          - "computeinstance-placeholder-gpu-1"
          - "computeinstance-placeholder-gpu-2"
    tolerations:
      - key: slurm.nebius.ai/taint
        operator: Equal
        value: cpu
        effect: NoSchedule
      - key: slurm.nebius.ai/taint
        operator: Equal
        value: gpu
        effect: NoSchedule
      - key: nvidia.com/gpu
        operator: Exists
        effect: NoSchedule
