pipeline {
    agent any

    stages {
        stage('Docker Build') {
            steps {
                // 싱글 쿼테이션 안에서 ${BUILD_NUMBER}가 정상 확장됩니다
                sh 'docker build --no-cache -t reporting-server:${BUILD_NUMBER} .'
            }
        }

        stage('Kind Image Load (Direct Inject)') {
            steps {
                sh 'docker save reporting-server:${BUILD_NUMBER} -o reporting-server.tar'
                sh 'docker cp reporting-server.tar kind-control-plane:/reporting-server.tar'
                sh 'docker exec kind-control-plane ctr -n k8s.io images import /reporting-server.tar'
                sh 'rm reporting-server.tar'
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                script {
                    // deployment.yaml 안의 이미지 태그를 현재 빌드 번호로 동적 변경 (변수명 통일)
                    sh "sed -i 's|image: reporting-server:.*|image: reporting-server:${BUILD_NUMBER}|g' deployment.yaml"
                    
                    // Always 정책이 적용된 yaml 파일을 쿠버네티스에 반영
                    sh "kubectl apply -f deployment.yaml"
                }
            }
        }
    }
}