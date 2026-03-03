package test.java;

import java.util.ArrayList;
import java.util.Scanner;

import main.java.algoritmos.Node;
import main.java.algoritmos.Tarjan;

public class TarjanTest {
    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);

        ArrayList<Node> grafo = InputFormatter.format(sc);

        Tarjan tj = new Tarjan();

        int count = tj.scc(grafo).size();
        System.out.println("Quantidade de SCC's: " + count);

        System.out.println(grafo.toString());
    }
}