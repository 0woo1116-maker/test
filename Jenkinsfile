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
                    
                    // 💡 핵심: export 명령어를 쓰면 127.0.0.1로 덮어씌워지므로 절대 쓰지 않고,
                    // 무조건 host.docker.internal:6444(우리가 뚫어놓은 고정 포트)로 강제 치환합니다.
                    sh "sed -i 's|server: https://.*|server: https://host.docker.internal:6444|g' /var/jenkins_home/.kube/config"
                    
                    // 쿠버네티스 배포 적용
                    sh "kubectl apply -f deployment.yaml --validate=false"
                    sh "kubectl rollout restart deployment/reporting-server-app"
                }
            }
        }
    }
}