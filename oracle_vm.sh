#!/bin/bash

# 유저 권한 체크 (sudo로 실행 방지)
if [ "$EUID" -eq 0 ]; then
  echo "오류: 이 스크립트는 sudo 없이 그냥 'sh oracle_vm.sh' 또는 './oracle_vm.sh'로 실행하세요."
  exit 1
fi

# 1. 시스템 업데이트 및 필수 패키지 설치
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y docker.io docker-compose-v2

# 2. 유저 권한 부여 (재접속 후 적용)
sudo usermod -aG docker $USER

# 3. Portainer 설정
mkdir -p ~/docker/portainer/data
cat <<EOF > ~/docker/portainer/docker-compose.yml
services:
  portainer:
    image: portainer/portainer-ce:latest
    container_name: portainer
    environment:
      - TZ=Asia/Seoul
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./data:/data
    networks:
      - net_main
    ports:
      - 9000:9000
    restart: always

networks:
  net_main:
    name: net_main
    driver: bridge
EOF

# 4. 실행 (하이픈 없이 docker compose 사용)
cd ~/docker/portainer
sudo docker compose up -d

echo "----------------------------------------------------"
echo "설치가 완료되었습니다!"
echo "Portainer 접속: http://[서버IP]:9000"
echo "----------------------------------------------------"
