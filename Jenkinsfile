pipeline {
    agent any

    stages {
        stage('Docker Build') {
            steps {
                // 빌드 번호(BUILD_NUMBER)를 태그로 사용하여 매번 새로운 이미지 생성
                sh 'docker build --no-cache -t reporting-server:${env.BUILD_NUMBER} .'
            }
        }

        stage('Kind Image Load (Direct Inject)') {
            steps {
                sh 'docker save reporting-server:${env.BUILD_NUMBER} -o reporting-server.tar'
                sh 'docker cp reporting-server.tar kind-control-plane:/reporting-server.tar'
                sh 'docker exec kind-control-plane ctr -n k8s.io images import /reporting-server.tar'
                sh 'rm reporting-server.tar'
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                // 쿠버네티스 Deployment의 이미지 릴리즈 버전을 동적으로 업데이트
                sh "kubectl set image deployment/reporting-server-app reporting-server-app=reporting-server:${env.BUILD_NUMBER}"
            }
        }
    }
}