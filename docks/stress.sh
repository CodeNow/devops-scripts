#!/bin/bash
#DEPS
service docker restart
docker pull ubuntu
docker pull runnable/image-builder

echo "start with 100 short live container"
for I in `seq 1 100`; do
  docker run -d ubuntu sleep 1
done
sleep 1

echo "start with 100 long live container"
for I in `seq 1 100`; do
  docker run -d ubuntu tail -f
done
sleep 60
docker kill `docker ps -q`

C=`docker run -d ubuntu tail -f /var/log/dpkg.log`
echo "run 100 short lived backround process"
for I in `seq 1 100`; do
  docker exec -it $C sleep 1
done

echo "run 100 short lived backround process parallel"
for I in `seq 1 100`; do
  docker exec -it $C sleep 1 &
done

echo "run 100 short lived backround process"
for I in `seq 1 100`; do
  docker exec -d $C  sleep 1
done

echo "run 100 short lived backround process in parallel"
for I in `seq 1 100`; do
  docker exec -d $C  sleep 1 &
done

echo "run 100 long lived backround process"
for I in `seq 1 100`; do
  docker exec -d $C  tail -f /var/log/dpkg.log
done

echo "run 100 long lived backround process in parallel"
for I in `seq 1 100`; do
  docker exec -d $C  tail -f /var/log/dpkg.log &
done

echo "build 100 containers"
for I in `seq 1 100`; do
  docker run -d -e RUNNABLE_AWS_ACCESS_KEY="AKIAIG7Y3M347VWVGNUQ" \
    -e RUNNABLE_AWS_SECRET_KEY="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" \
    -e RUNNABLE_FILES_BUCKET="runnable.context.resources.production" \
    -e RUNNABLE_PREFIX="54654f4763768e0d00f23f4d/source/" \
    -e RUNNABLE_FILES="{\"54654f4763768e0d00f23f4d/source/\":\"J2Ux0OFZrUD_XWK3hICXPkbMO3JODRkt\",\"54654f4763768e0d00f23f4d/source/Dockerfile\":\"vD0iLbLAbvFBebLGQHafs7ecEdytkSEc\"}" \
    -e RUNNABLE_DOCKER="unix:///var/run/docker.sock" \
    -e RUNNABLE_DOCKERTAG="registry.runnable.com/2194285/54654f4763768e0d00f23f4d:546693ed78902c1000026daa" \
    -e RUNNABLE_REPO="git@github.com:anandkumarpatel/gossip" \
    -e RUNNABLE_COMMITISH="106c5459a4f71851dc5ced408014a51dd1eea3ae" \
    -e RUNNABLE_KEYS_BUCKET="runnable.deploykeys.production" \
    -e RUNNABLE_DEPLOYKEY="anandkumarpatel/gossip.key" \
    -e PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    -e HOME="/root" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    runnable/image-builder
done

echo "build 100 containers in parrallel"
for I in `seq 1 100`; do
  docker run -d -e RUNNABLE_AWS_ACCESS_KEY="AKIAIG7Y3M347VWVGNUQ" \
    -e RUNNABLE_AWS_SECRET_KEY="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" \
    -e RUNNABLE_FILES_BUCKET="runnable.context.resources.production" \
    -e RUNNABLE_PREFIX="54654f4763768e0d00f23f4d/source/" \
    -e RUNNABLE_FILES="{\"54654f4763768e0d00f23f4d/source/\":\"J2Ux0OFZrUD_XWK3hICXPkbMO3JODRkt\",\"54654f4763768e0d00f23f4d/source/Dockerfile\":\"vD0iLbLAbvFBebLGQHafs7ecEdytkSEc\"}" \
    -e RUNNABLE_DOCKER="unix:///var/run/docker.sock" \
    -e RUNNABLE_DOCKERTAG="registry.runnable.com/2194285/54654f4763768e0d00f23f4d:546693ed78902c1000026daa" \
    -e RUNNABLE_REPO="git@github.com:anandkumarpatel/gossip" \
    -e RUNNABLE_COMMITISH="106c5459a4f71851dc5ced408014a51dd1eea3ae" \
    -e RUNNABLE_KEYS_BUCKET="runnable.deploykeys.production" \
    -e RUNNABLE_DEPLOYKEY="anandkumarpatel/gossip.key" \
    -e PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin" \
    -e HOME="/root" \
    -v /var/run/docker.sock:/var/run/docker.sock \
    runnable/image-builder &
done

echo "start/kill 100 long lived process"
for I in `seq 1 100`; do
  C=`docker run -d  ubuntu tail -f /var/log/dpkg.log`
  docker kill $C
done

echo "start/kill 100 long lived process in parallel"
for I in `seq 1 100`; do
  C=`docker run -d  ubuntu tail -f /var/log/dpkg.log`
  docker kill $C &
done

echo "use all the ports"
for I in `seq 1 100`; do
  docker run  -p 1 -p 2 -p 3 -p 4 -p 5 -p 6 -p 7 -p 8 -p 9 -p 10 -p 11 -p 12 -p 13 -p 14 -p 15 -p 16 -p 17 -p 18 -p 19 -p 20 -p 21 -p 22 -p 23 -p 24 -p 25 -p 26 -p 27 -p 28 -p 29 -p 30 -p 31 -p 32 -p 33 -p 34 -p 35 -p 36 -p 37 -p 38 -p 39 -p 40 -p 41 -p 42 -p 43 -p 44 -p 45 -p 46 -p 47 -p 48 -p 49 -p 50 -p 51 -p 52 -p 53 -p 54 -p 55 -p 56 -p 57 -p 58 -p 59 -p 60 -p 61 -p 62 -p 63 -p 64 -p 65 -p 66 -p 67 -p 68 -p 69 -p 70 -p 71 -p 72 -p 73 -p 74 -p 75 -p 76 -p 77 -p 78 -p 79 -p 80 -p 81 -p 82 -p 83 -p 84 -p 85 -p 86 -p 87 -p 88 -p 89 -p 90 -p 91 -p 92 -p 93 -p 94 -p 95 -p 96 -p 97 -p 98 -p 99 -p 100 -p 101 -p 102 -p 103 -p 104 -p 105 -p 106 -p 107 -p 108 -p 109 -p 110 -p 111 -p 112 -p 113 -p 114 -p 115 -p 116 -p 117 -p 118 -p 119 -p 120 -p 121 -p 122 -p 123 -p 124 -p 125 -p 126 -p 127 -p 128 -p 129 -p 130 -p 131 -p 132 -p 133 -p 134 -p 135 -p 136 -p 137 -p 138 -p 139 -p 140 -p 141 -p 142 -p 143 -p 144 -p 145 -p 146 -p 147 -p 148 -p 149 -p 150 -p 151 -p 152 -p 153 -p 154 -p 155 -p 156 -p 157 -p 158 -p 159 -p 160 -p 161 -p 162 -p 163 \
   -d  ubuntu tail -f /var/log/dpkg.log
done

docker kill `docker ps -q`

echo "use all the ports ensure no error"
for I in `seq 1 100`; do
  docker run  -p 1 -p 2 -p 3 -p 4 -p 5 -p 6 -p 7 -p 8 -p 9 -p 10 -p 11 -p 12 -p 13 -p 14 -p 15 -p 16 -p 17 -p 18 -p 19 -p 20 -p 21 -p 22 -p 23 -p 24 -p 25 -p 26 -p 27 -p 28 -p 29 -p 30 -p 31 -p 32 -p 33 -p 34 -p 35 -p 36 -p 37 -p 38 -p 39 -p 40 -p 41 -p 42 -p 43 -p 44 -p 45 -p 46 -p 47 -p 48 -p 49 -p 50 -p 51 -p 52 -p 53 -p 54 -p 55 -p 56 -p 57 -p 58 -p 59 -p 60 -p 61 -p 62 -p 63 -p 64 -p 65 -p 66 -p 67 -p 68 -p 69 -p 70 -p 71 -p 72 -p 73 -p 74 -p 75 -p 76 -p 77 -p 78 -p 79 -p 80 -p 81 -p 82 -p 83 -p 84 -p 85 -p 86 -p 87 -p 88 -p 89 -p 90 -p 91 -p 92 -p 93 -p 94 -p 95 -p 96 -p 97 -p 98 -p 99 -p 100 -p 101 -p 102 -p 103 -p 104 -p 105 -p 106 -p 107 -p 108 -p 109 -p 110 -p 111 -p 112 -p 113 -p 114 -p 115 -p 116 -p 117 -p 118 -p 119 -p 120 -p 121 -p 122 -p 123 -p 124 -p 125 -p 126 -p 127 -p 128 -p 129 -p 130 -p 131 -p 132 -p 133 -p 134 -p 135 -p 136 -p 137 -p 138 -p 139 -p 140 -p 141 -p 142 -p 143 -p 144 -p 145 -p 146 -p 147 -p 148 -p 149 -p 150 -p 151 -p 152 -p 153 -p 154 -p 155 -p 156 -p 157 -p 158 -p 159 -p 160 -p 161 -p 162 -p 163 \
   -d  ubuntu tail -f /var/log/dpkg.log
done