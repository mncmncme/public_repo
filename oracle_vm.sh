#!/bin/bash

# 1. 현재 실행 유저 확인 (절대 root로 실행하지 마세요 안내)
if [ "$EUID" -eq 0 ]; then
  echo "오류: 이 스크립트를 'sudo'로 실행하지 마세요."
  echo "그냥 'sh run.sh' 또는 './run.sh'로 실행하십시오."
  exit 1
fi

# 2. 업데이트 및 Docker 설치 (내부에서 필요한 부분만 sudo 사용)
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y docker.io docker-compose

# 3. 현재 유저를 docker 그룹에 추가 (나중에 sudo 없이 docker 쓰기 위함)
sudo usermod -aG docker $USER

# 4. 디렉토리 생성 (현재 유저의 홈 디렉토리에 생성됨)
DOCKER_ROOT="$HOME/docker/portainer"
mkdir -p "$DOCKER_ROOT/data"

# 5. docker-compose.yml 작성
cat <<EOF > "$DOCKER_ROOT/docker-compose.yml"
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

# 6. 실행
cd "$DOCKER_ROOT"
# 현재 세션에서 그룹 변경을 즉시 적용하기 위해 sudo 사용
sudo docker-compose up -d

echo "----------------------------------------------------"
echo "설치가 완료되었습니다!"
echo "Portainer 접속: http://[서버IP]:9000"
echo "주의: 그룹 변경 적용을 위해 'exit' 후 다시 SSH 접속을 권장합니다."
echo "----------------------------------------------------"
