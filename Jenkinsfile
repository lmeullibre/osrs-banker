pipeline {
  agent any

  environment {
    APP = "svelte-sample"
    BUILD = "${JOB_NAME.replace('/', '-')}-${BUILD_NUMBER}"
    EMAIL = "anton@codeborne.com"
    GIT_LAST_CHANGE = sh(script: 'git show', returnStdout: true)
    EMAIL_BODY = "Project: ${JOB_NAME}\nBuild Number: ${BUILD_NUMBER}\n\nLast change:\n\n${env.GIT_LAST_CHANGE}"
    COMPOSE = "docker-compose -f docker-compose.yml -p $APP"
    VERSION = sh(script: 'git describe --tags --always --long', returnStdout: true).trim()
    RUN_TESTS = "docker run --network ${APP}_default -e BUILD=$BUILD"
  }

  stages {
    stage('Build UI') {
      steps {
        sh "docker build --target build-ui -t ${BUILD}_ui ."
      }
    }
    stage('Test UI') {
      steps {
        sh "docker run -t ${BUILD}_ui npm run test"
      }
    }
    stage('Build final') {
      when {
        branch 'master'
      }
      steps {
        sh "docker build --target final --build-arg VERSION=$VERSION -t ${APP}_${APP} ."
      }
    }
    stage('Deploy') {
      when {
         branch 'master'
      }
      steps {
        sh "$COMPOSE up -d --remove-orphans"
        script {
          def startLogs = sh script: "sleep 7 && $COMPOSE logs $APP", returnStdout: true
          println(startLogs)
          if (!startLogs.contains("Listening on")) error("Failed to start")
          if (EMAIL) mail to: EMAIL, subject: "$APP deployed to test", body: EMAIL_BODY + "\n\nStart logs:\n...\n$startLogs"
        }
      }
    }
  }
  post {
    always {
      sh 'rm -fr build && mkdir -p build/test-results'
      sh 'docker cp ${BUILD}_test:/app/domain/build/test-results build/ && docker cp ${BUILD}_test:/app/app/build/test-results build/ && docker rm ${BUILD}_test || echo "No test container"'
      sh "touch build/test-results/**/*.xml"
      junit 'build/test-results/**/*.xml'
    }
    failure {
      script {
        if (EMAIL) mail to: EMAIL, subject: "$APP ($BRANCH_NAME) build failed", body: EMAIL_BODY
      }
    }
  }
}
