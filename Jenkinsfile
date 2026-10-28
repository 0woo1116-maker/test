pipeline {
    agent any

    stages {
        // 빌드 시작 직후 안전하게 워크스페이스를 비우는 스테이지
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }

        stage('Checkout') {
            steps {
                git branch: 'dev', url: 'https://github.com/0woo1116-maker/test.git'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build --no-cache -t reporting-server:${BUILD_NUMBER} .'
            }
        }

        stage('Kind Image Load') {
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
                    sh "sed -i 's|image: reporting-server:.*|image: reporting-server:${BUILD_NUMBER}|g' deployment.yaml"
                    
                    // 1. kubeconfig 내보내기
                    sh "kind export kubeconfig --name kind"
                    
                    // 💡 [핵심 추가] 젠킨스 컨테이너 내부에서 호스트/컨트롤플레인으로 접근할 수 있도록 주소 변환
                    // (kind-control-plane 컨테이너 이름 또는 내부 네트워크 IP로 매핑)
                    sh "sed -i 's/127\\.0\\.0\\.1/kind-control-plane/g' /var/jenkins_home/.kube/config"
                    
                    // 2. 쿠버네티스 배포 적용
                    sh "kubectl apply -f deployment.yaml --validate=false"
                    sh "kubectl rollout restart deployment/reporting-server-app"
                }
            }
        }
    }
}