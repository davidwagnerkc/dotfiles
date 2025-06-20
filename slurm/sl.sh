mapfile -t nodes < <(sinfo -h -p research -o "%n %G" | grep -v null | awk '{print $1}' | sort)
host=$(hostname -s)
host_base=${host::-2}
fmt="%12P %20j %8u %12M %12l %5C %14b"
NIX_SHELL='NP_RUNTIME=bwrap nix develop $HOME/git/dotfiles/'

case "${1:-}" in
  status)
    eval "$(conda shell.bash hook)"
    conda activate zdev
    for node in "${nodes[@]}"; do
      echo -n "${node: -2} "
      squeue -h -w $node -t R -o "%C %b %G" \
          | python -c "
import sys
cpus = 0
gpus = 0
for line in sys.stdin:
    cpu, gpu, _ = line.split()
    try:
        num_gpus = int(gpu.split(':')[-1])
    except:
        pass
    try:
        num_cpus = int(cpu.split(':')[-1])
    except:
        pass
    gpus += num_gpus
    cpus += num_cpus
print(f'CPU: {cpus:2d}/128 GPU:{gpus}/8')
      "
    done
    ;;
  usage)
    for node in "${nodes[@]}"; do
      echo "===== $node ====="
      squeue -h \
        -w "$node" \
        -o "$fmt"
      echo
    done
    ;;
  nodes)
    for node in "${nodes[@]}"; do
      echo "===== $node ====="
      scontrol show node=$node | egrep -v "(ExtSen|Watts|AllocTRES|ActiveF|NodeAddr|Part|BootTime|LastBusy|Linux|Gres=|MemSpec|State=|billing)"
      echo
    done
    ;;
  scratch)
    for node in "${nodes[@]}"; do
      echo "===== $node ====="
      srun -p research -t30 -w $node df -h /scratch
      echo
    done
    ;;
  quota)
    quota -s
    ;;
  q)
    squeue -u $USER
    ;;
  proc)
    ps -u "$USER" \
      -o pid,tty,etime,%cpu,%mem,cmd \
      --forest \
      --sort=start_time
    ;;
  log)
    f=$(ls -1t $HOME/logs/ | head -n1)
    cat $HOME/logs/$f
    ;;
  cp)
    # if [ -n "$TMUX" ]; then
    #   MSG='\ePtmux;\e\e]52;c;%s\a\e\\'
    # else
    #   MSG='\e]52;c;%s\a'
    # fi
    MSG='\e]52;c;%s\a'
    [[ -t 0 ]] || base64 | tr -d '\n' | xargs -0 printf "$MSG"
    ;;
  dev)
    CPUS=8
    GPUS=0
    TIME=00:60:00 
    shift
    while getopts ":c:g:t:" opt; do
      echo $opt
      case "$opt" in
        c) CPUS=$OPTARG      ;;
        g) GPUS=$OPTARG      ;;
        t) 
           if [[ $OPTARG =~ ^[0-9]+$ ]]; then
             TIME=$(printf "00:%02d:00" "$OPTARG")
           else
             TIME=$OPTARG
           fi
           ;;
        *) 
           echo "Usage: $0 dev [-c cpus] [-g gpus] [-t minutes|HH:MM:SS] e.g. sl dev -c16 -g1 -t30 or sl dev -t12:00:00" >&2
           exit 1
           ;;
      esac
    done
    shift $((OPTIND-1))
    if [[ "$(hostname -s)" != *-ln01 ]]; then
      echo "Probably only want to run this from login node..."
      exit 1
    fi
    JOB_ID=$(squeue -u $USER -n dev -t PENDING,RUNNING -o "%i" -h)
    if [[ -n $JOB_ID ]]; then
        echo "Found running job $JOB_ID."
    else
        JOB_ID=$(
            sbatch \
                --parsable \
                --job-name=dev \
                --partition=research \
                --ntasks=1 \
                --cpus-per-task=$CPUS \
                --gres=gpu:$GPUS \
                --time=$TIME \
                --output=/home/dwcgt/logs/%j.log \
                --error=/home/dwcgt/logs/%j.log \
                --open-mode=append \
                --export=NONE \
    	        --wrap='sleep infinity'
        )
        echo "Submitted job $JOB_ID — waiting for it to start…"
        while [[ $(squeue -h -j $JOB_ID -o "%T") != RUNNING ]]; do sleep 1; done
    fi
    echo "Starting shell in job $JOB_ID…"
    srun \
        --ntasks=1 \
        --cpus-per-task=$CPUS \
        --gres=gpu:$GPUS \
        --jobid="$JOB_ID" \
        --pty bash -lic "$NIX_SHELL";;
  shell)
    host=${2:+-w $host_base$2}
    echo "Starting on $host..."
    srun -p research -t120 $host --pty bash -lic "$NIX_SHELL"
    ;;
  edit)
    if command -v nvim >/dev/null 2>&1; then
      nvim $HOME/git/dotfiles/slurm/sl.sh
    else
      vim $HOME/git/dotfiles/slurm/sl.sh
    fi
    ;;
  affinity)
    echo "$(nproc)/$(nproc --all)"
    nvidia-smi
    ;;
  *)
    echo "Nope..."
    echo
    exit 1
    ;;
esac
