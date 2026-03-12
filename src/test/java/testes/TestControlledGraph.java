package testes;

import java.util.ArrayList;

import org.junit.jupiter.api.Test;
import static org.junit.jupiter.api.Assertions.assertEquals;

import algoritmos.Kosaraju;
import algoritmos.Node;
import algoritmos.Tarjan;

public class TestControlledGraph {

    @Test
    public void testRandomGraphsTarjan1() throws Exception {

        for (int i = 0; i < 100; i++) {

            int expected = 10;

            ArrayList<Node> grafo = GraphGenerator.generateGraph(50, 200, expected);

            ArrayList<Node> grafoTarjan = grafo;
            Tarjan tarjan = new Tarjan();
            int sccTarjan = tarjan.findSCCs(grafoTarjan).size();            
            assertEquals(expected, sccTarjan);

        }
    }

    @Test
    public void testRandomGraphsTarjan2() throws Exception {

        for (int i = 0; i < 100; i++) {

            int expected = 500;

            ArrayList<Node> grafo = GraphGenerator.generateGraph(1000, 3000, expected);

            ArrayList<Node> grafoTarjan = grafo;
            Tarjan tarjan = new Tarjan();
            int sccTarjan = tarjan.findSCCs(grafoTarjan).size();            
            assertEquals(expected, sccTarjan);

        }
    }

    @Test
    public void testRandomGraphsKosaraju1() throws Exception {

        for (int i = 0; i < 100; i++) {

            int expected = 10;

            ArrayList<Node> grafo = GraphGenerator.generateGraph(50, 200, expected);
            
            ArrayList<Node> grafoKosaraju = grafo;
            Kosaraju kosaraju = new Kosaraju();
            int sccKosaraju = kosaraju.findSCCs(grafoKosaraju).size();
            assertEquals(expected, sccKosaraju);
        }
    }

    @Test
    public void testRandomGraphsKosaraju2() throws Exception {

        for (int i = 0; i < 100; i++) {

            int expected = 500;

            ArrayList<Node> grafo = GraphGenerator.generateGraph(1000, 3000, expected);
            
            ArrayList<Node> grafoKosaraju = grafo;
            Kosaraju kosaraju = new Kosaraju();
            int sccKosaraju = kosaraju.findSCCs(grafoKosaraju).size();
            assertEquals(expected, sccKosaraju);
        }
    }
}