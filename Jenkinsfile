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
                    
                    // 💡 export 명령어를 쓰지 않고, 마운트된 쿠버네티스 설정 경로를 명시하거나 바로 적용
                    // 컨테이너 구동 시 -v C:\Users\M2S\.kube:/var/jenkins_home/.kube 로 연결되어 있으므로
                    // 호스트에 이미 정상 설정된 kubeconfig를 환경 변수로 바로 지정해 줍니다.
                    env.KUBECONFIG = "/var/jenkins_home/.kube/config"

                    // 바로 쿠버네티스 배포 적용
                    sh "kubectl apply -f deployment.yaml --validate=false"
                    sh "kubectl rollout restart deployment/reporting-server-app"
                }
            }
        }
    }
}