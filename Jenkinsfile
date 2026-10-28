pipeline {
    agent any

    // 💡 아래 options 블록을 추가합니다!
    options {
        // 빌드 시작 전 작업 공간을 깨끗이 비우고 Git 캐시 꼬임 방지
        cleanWs()
    }

    stages {
        stage('Docker Build') {
            steps {
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
                    sh "sed -i 's|image: reporting-server:.*|image: reporting-server:${BUILD_NUMBER}|g' deployment.yaml"
                    
                    // 💡 핵심: 젠킨스가 kind 클러스터를 바라보도록 컨텍스트를 강제로 전환합니다!
                    sh "kubectl config use-context kind-kind"
                    
                    // 기존 배포 명령어 실행 (--validate=false 유지)
                    sh "kubectl apply -f deployment.yaml --validate=false"
                    sh "kubectl rollout restart deployment/reporting-server-app"
                }
            }
        }
    }
}