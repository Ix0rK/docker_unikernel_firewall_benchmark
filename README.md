
#Use Full command to run docker builder
docker run -it --mount  type=bind,src=$PWD/osv-images,dst=/osv-images rsx217-osv-builder bash -c "cp -r ~/.capstan/repository/*-rsx217 /osv-images"
