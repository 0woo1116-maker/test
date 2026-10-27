# 1. 톰캣이 포함된 공식 자바 런타임 이미지 사용
FROM tomcat:9.0-jdk11-temurin

# 2. 기존 톰캣의 기본 webapps 내용을 비우거나 ROOT 폴더 삭제
RUN rm -rf /usr/local/tomcat/webapps/*

# 3. ReportingServer 폴더 자체를 컨테이너 내부의 /usr/local/tomcat/webapps/ReportingServer 로 복사
# 이렇게 하면 자동으로 http://<주소>/ReportingServer/ 경로로 인식됩니다.
COPY . /usr/local/tomcat/webapps/ReportingServer

# 4. 톰캣 기본 포트 노출
EXPOSE 8080

# 5. 톰캣 서버 실행
CMD ["catalina.sh", "run"]