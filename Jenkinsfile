pipeline {
    agent any

    stages {
        stage('Docker Build') {
            steps {
                // 현재 빌드 번호 태그로 도커 이미지 빌드
                sh 'docker build --no-cache -t reporting-server:${BUILD_NUMBER} .'
            }
        }

        stage('Kind Image Load (Direct Inject)') {
            steps {
                // 이미지를 tar로 추출 후 kind 클러스터 내부로 직접 주입
                sh 'docker save reporting-server:${BUILD_NUMBER} -o reporting-server.tar'
                sh 'docker cp reporting-server.tar kind-control-plane:/reporting-server.tar'
                sh 'docker exec kind-control-plane ctr -n k8s.io images import /reporting-server.tar'
                sh 'rm reporting-server.tar'
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                script {
                    // 1. deployment.yaml 파일의 이미지 태그를 현재 빌드 번호로 동적 치환
                    sh "sed -i 's|image: reporting-server:.*|image: reporting-server:${BUILD_NUMBER}|g' deployment.yaml"
                    
                    // 2. 쿠버네티스에 변경된 설정 적용
                    sh "kubectl apply -f deployment.yaml"
                    
                    // 3. 구버전 파드를 내리고 새 이미지 태그를 장착한 파드로 강제 재기동
                    sh "kubectl rollout restart deployment/reporting-server-app"
                }
            }
        }
    }
}