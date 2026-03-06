# Imagem base com Java já instalado
FROM openjdk:17-slim

# Pasta de trabalho dentro do container
WORKDIR /app

# Copia todo o código fonte para dentro do container
COPY src/ src/

# Compila todas as classes Java
RUN javac -d out src/main/java/algoritmos/.java src/test/java/.java

# Quando o container rodar, executa o KosarajuTest
CMD ["java", "-cp", "out", "test.java.KosarajuTest"]