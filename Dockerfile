# 1. 톰캣이 포함된 공식 자바 런타임 이미지 사용 (프로젝트 자바 버전에 맞춰 필요시 11이나 17로 변경 가능)
FROM tomcat:9.0-jdk11-temurin

# 2. 작업 디렉토리를 톰캣의 기본 웹앱 경로(ROOT)로 설정
WORKDIR /usr/local/tomcat/webapps/ROOT

# 3. 현재 ReportingServer 폴더의 모든 파일을 컨테이너 내부의 ROOT 디렉토리로 복사
COPY . /usr/local/tomcat/webapps/ROOT

# 4. 톰캣 기본 포트 노출
EXPOSE 8080

# 5. 톰캣 서버 실행 (Catalina)
CMD ["catalina.sh", "run"]