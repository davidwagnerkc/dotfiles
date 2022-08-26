GCP_PROJECT=project
GCP_ZONE=us-central1-a
GCP_VM_NAME=dev
GCP_MACHINE_TYPE=c2-standard-8
gcloud compute instances create $GCP_VM_NAME \
    --project=$GCP_PROJECT \
    --zone=$GCP_ZONE \
    --machine-type=$GCP_MACHINE_TYPE \
    --no-restart-on-failure \
    --maintenance-policy=TERMINATE \
    --preemptible \
    --create-disk=auto-delete=yes,boot=yes,device-name=$GCP_VM_NAME,image=projects/ml-images/global/images/c0-deeplearning-common-cu113-v20220227-debian-10,size=250,type=projects/$GCP_PROJECT/zones/$GCP_ZONE/diskTypes/pd-balanced \
    --no-shielded-secure-boot \
    --shielded-vtpm \
    --shielded-integrity-monitoring \
    --reservation-affinity=any
