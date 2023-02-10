# Welcome ! 
This project aims to provide a reproducible benchmark between docker and OSv (containerisation vs virtualisation) regarding a firewall function.  
> Warning : This source code is provided for a final project of a Network Course.   
> So, it's mainly for education purpose.  

## How to run the Benchmark ?
First clone this repos in a VM.   
This code was tested on Ubuntu Server.  

### Docker
Simply run docker-compose file inside de repository with bash time function   
````
cd rsx217-mini-project
time docker-compose -f ./docker-compose.yml up --build
````
Look at the logs !  
### OSv
For OSv it's more complicated ... and the used code is mainly homemade   
1. Build OSv image using the dockerize environnement given by [cloudius-system](https://github.com/cloudius-systems/osv).  
````
docker build -f ./osv_builder.DockerFile -t rsx217-osv-builder .
````
2. Retrieve qemu images (OSv as QEMU) on the running container  
````
docker run -it --mount  type=bind,src=$PWD/osv-images,dst=/osv-images rsx217-osv-builder bash -c "cp -r ~/.capstan/repository/*-rsx217 /osv-images"
````
3. Run the homemade deployement script  
````
./osv-runner.sh
````
4. Look at the logs ! If they look messy it's normal jaja 
> Warning for fast deployement this script needs sudo priviliege to create all the network infrastructure  
> Be aware of that and run in it in a test enviromment.  
### Results 
You might have as result this metrics. 
|             | DOCKER             | OSV                |
|-------------|--------------------|--------------------|
| Time        |                    |                    |
|-------------|--------------------|--------------------|
| real        | 0m3.309s           | 0m9.180s           |
| user        | 0M0.319s           | 0m0256s            |
| sys         | 0m0.046s           | 0M0289s            |
|-------------|--------------------|--------------------|
| Request     |                    |                    |
|-------------|--------------------|--------------------|
| ByPass      | Operation timedout | Connection Refused |
| Simple      | 0.0218ms           | 0.0662ms           |
| Redirection | 0.0405ms           | 0.0822ms           |
|-------------|--------------------|--------------------|
| Image Size  | ~70MB              | ~24MB              |
|-------------|--------------------|--------------------|

### A Rapport is avaible - french only :)
- rapport-KELLER-rsx217.pdf
