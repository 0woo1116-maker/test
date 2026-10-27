pipeline {
    agent any

    stages {
        stage('Docker Build') {
            steps {
                // 싱글 쿼테이션과 셸 표준 문법 사용
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
                // 컨테이너 이름을 reporting-server로 정확하게 지정
                sh 'kubectl set image deployment/reporting-server-app reporting-server=reporting-server:${BUILD_NUMBER}'
            }
        }
    }
}