pipeline {
    agent any

    stages {
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
                script {
                    sh "docker build --no-cache -t reporting-server:${BUILD_NUMBER} ."
                }
            }
        }

        stage('Kind Image Load') {
            steps {
                script {
                    sh "docker save reporting-server:${BUILD_NUMBER} -o reporting-server.tar"
                    sh "docker cp reporting-server.tar kind-control-plane:/reporting-server.tar"
                    sh "docker exec kind-control-plane ctr -n k8s.io images import /reporting-server.tar"
                    sh "rm reporting-server.tar"
                }
            }
        }

        stage('Kubernetes Deploy') {
            steps {
                script {
                    // 1. 디플로이먼트 파일의 이미지 태그를 현재 빌드 번호로 교체
                    sh "sed -i 's|image: reporting-server:.*|image: reporting-server:${BUILD_NUMBER}|g' deployment.yaml"
                    
                    // 2. sed를 쓰지 않고 kubectl 내장 명령어로 안전하게 클러스터 서버 주소만 변경 (YAML 손상 원천 차단)
                    sh '''
                        CLUSTER_NAME=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
                        if [ -z "$CLUSTER_NAME" ]; then
                            CLUSTER_NAME="kind-kind"
                        fi
                        echo "Target Cluster Name: $CLUSTER_NAME"
                        
                        // 호스트 포트 6444를 통해 Kind API 서버로 안전하게 연결 설정
                        kubectl config set-cluster "$CLUSTER_NAME" --server=https://host.docker.internal:6444
                    '''
                    
                    // 3. 쿠버네티스 배포 적용 및 재시작
                    sh "kubectl apply -f deployment.yaml --validate=false"
                    sh "kubectl rollout restart deployment/reporting-server-app"
                }
            }
        }
    }
}