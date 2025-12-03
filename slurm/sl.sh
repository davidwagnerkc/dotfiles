: << 'EOF'
(sl) entrypoint for research development environments, jobs, SLURM utilities, etc. 

(sl dev) dev env entrypoint 
  - Creates or re-uses sbatch job named "dev" on research partition
  - Requests CPUS, GPUS, TIME
  - sbatch entrypoint
    - nix develop (uses ~/git/dotfiles/flake.nix)
      - Creates or re-uses tmux session named "dev"
      - Handles apt deps
      - sources ~/.bashrc which in turn sources ~/.bashrc.slurmy 
        - handles both non-nix and nix shell envs (login node vs job node)
        - purge modules
        - sync and activate venv (uses ~/git/research/pyproject.toml)
        - vi, PATH, autocomplete, PS1, etc.
      - Its own entrypoint is ~/git/dotfiles/slurm/start-tmux.sh
        - Creates or re-uses tmux session named "jl"
        - Assumes venv activated from above
        - Starts jupyter lab in ~/git/research/notebooks
        - URL written out to connection-url.txt
      - Then sleeps forever
  - srun interactive loging shell with nix develop entrypoint

  Scripts:
    sl.sh
      -> flake.nix
        -> .bashrc (.bashrc.slurmy)
          -> pyproject.toml
          -> start-tmux.sh

  Shells:
    mbp bash
      -> ssh login node bash
        -> sbatch --wrap compute node bash
          -> nix develop bash
            -> tmux session "dev"
EOF
mapfile -t nodes < <(sinfo -h -p research -o "%n %G" | grep -v null | awk '{print $1}' | sort)
host=$(hostname -s)
host_base="kc-sse-ml-rn"
fmt="%12P %20j %8u %12M %12l %5C %14b"
NIX_SHELL='NP_RUNTIME=bwrap nix develop $HOME/git/dotfiles/'

cp () {
    [[ -t 0 ]] || base64 | tr -d '\n' | xargs -0 printf '\e]52;c;%s\a'
}

case "${1:-}" in
  switch)
    if [[ -n $VIRTUAL_ENV ]]; then
      cmd="deactivate && deactivate_path && conda activate pderefiner"
    else
      cmd="conda deactivate && source $HOME/git/research/.venv/bin/activate"
    fi
    tmux send-keys -R C-m
    tmux send-keys -R C-m
    tmux send-keys -R -l "${cmd}"
    ;;
  status)
    source $HOME/git/research/.venv/bin/activate
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
        num_gpus = 0
    try:
        num_cpus = int(cpu.split(':')[-1])
    except:
        num_cpus = 0
    gpus += num_gpus
    cpus += num_cpus
print(f'CPU: {cpus:2d}/128 GPU:{gpus}/8')
      "
    done
    ;;
  jl)
    echo $JL_URL | base64 | tr -d '\n' | xargs -0 printf '\e]52;c;%s\a'
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
      -o pid,tty,start_time,etime,%cpu,%mem,cmd \
      --sort=start_time
    echo
    echo
    ps -u "$USER" \
      -o pid,tty,start_time,etime,%cpu,%mem,cmd \
      --forest
    ;;
  log)
    f=$(ls -1t $HOME/logs/ | head -n1)
    cat $HOME/logs/$f
    ;;
  cp)
    [[ -t 0 ]] || base64 | tr -d '\n' | xargs -0 printf '\e]52;c;%s\a'
    ;;
  dev)
    CPUS=32
    GPUS=1
    TIME=02:00:00 
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
        # --exclude=kc-sse-ml-rn04,kc-sse-ml-rn05 \
        # --exclude=kc-sse-ml-rn04 \
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
                --wrap="NP_RUNTIME=bwrap nix develop $HOME/git/dotfiles/ --command $HOME/git/dotfiles/slurm/start-tmux.sh; sleep infinity"
        )
        echo "Submitted job $JOB_ID — waiting for it to start…"
        while [[ $(squeue -h -j $JOB_ID -o "%T") != RUNNING ]]; do sleep 1; done
    fi
    sleep 1
    echo "Starting shell in job $JOB_ID…"
    srun \
        --ntasks=1 \
        --cpus-per-task=$CPUS \
        --gres=gpu:$GPUS \
        --jobid="$JOB_ID" \
        --pty bash -lic "$NIX_SHELL"
    ;;
  shell)
    host=${2:+-w $host_base$2}
    echo "Starting on $host..."
    srun -p research -t120 $host --pty bash -lic "$NIX_SHELL"
    ;;
  shellbash)
    host=${2:+-w $host_base$2}
    echo "Starting on $host..."
    srun -p research -t120 $host --pty bash -li
    ;;
  edit)
    target=${2:-sl}
    $EDITOR ~/git/dotfiles/slurm/sl.sh ~/git/dotfiles/flake.nix ~/git/dotfiles/.bashrc.slurmy ~/git/dotfiles/slurm/start-tmux.sh
    # case "$target" in
    #   sl)
    #     $EDITOR ~/git/dotfiles/slurm/sl.sh
    #     ;;
    #   nix)
    #     $EDITOR ~/git/dotfiles/flake.nix
    #     ;;
    #   vim)
    #     $EDITOR ~/git/dotfiles/init.vim
    #     ;;
    #   *)
    #     echo "Usage: sl edit [sl|nix|vim]"
    #     exit 1
    #     ;;
    # esac
    ;;
  nix)
    if command -v nvim >/dev/null 2>&1; then
      nvim $HOME/git/dotfiles/flake.nix
    else
      vim $HOME/git/dotfiles/flake.nix
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
