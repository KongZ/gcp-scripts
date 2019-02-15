function kgpozo() {
    list=$(kubectl get pods -o=wide)
    zones=()
    for pod in $(awk '{if (NR!=1) {print $1}}' <<< "$list"); do
        pod_zone=$(kubectl get pods $pod --no-headers=true -o wide | awk '{print $7}' | xargs kubectl get node --no-headers=true -Lfailure-domain.beta.kubernetes.io/zone | awk '{print $6}')
        zones+=($pod_zone)
    done
    awk -v var="${zones[*]}" 'BEGIN {ARGC--} {split(var,list); if (NR==1) {print $0,"\t","ZONE"} else {print $0,"\t",list[NR-1]}}' <<< "$list"
}
