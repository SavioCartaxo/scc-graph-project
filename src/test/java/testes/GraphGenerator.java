package testes;

import java.util.ArrayList;
import java.util.Scanner;

import algoritmos.Node;
import util.InputFormatter;

public class GraphGenerator {

    public static ArrayList<Node> generateGraph(int n, int m, int k) throws Exception {

        ProcessBuilder pb = new ProcessBuilder(
                "python",
                "scripts/generate_inputs/script_controlled_graph.py",
                String.valueOf(n),
                String.valueOf(m),
                String.valueOf(k)
        );

        Process process = pb.start();

        Scanner sc = new Scanner(process.getInputStream());

        ArrayList<Node> grafo = InputFormatter.format(sc);

        process.waitFor();

        sc.close();

        return grafo;
    }
}