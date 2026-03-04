package main.java.algoritmos;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.util.*;

public class Tarjan{
    private ArrayList<Node> graph;
    private static int UNVISITED = -1;
    private int id;
    private Map<Integer, Integer> ids; // Usado para dizer se um nó foi ou não visitado
    private Map<Integer, Integer> low; // Usado para dar a cada nó um Low Link Value
    private Set<Integer> onStack;  // Diz se cada nó está atualmente na pilha;
    private ArrayList<Integer> stack; 
    private ArrayList<ArrayList<Integer>> out; // Saída a qual cada elemento da lista é um SCC
    private int countSCC;


    //public static int count_scc(ArrayList<ArrayList<int>> vector){
    //}

    public ArrayList<ArrayList<Integer>> scc(ArrayList<Node> graph){
        // iniciando variáveis
        this.graph = graph;
        int n = graph.size();
        
        ids = new HashMap<>();
        low = new HashMap<>();
        onStack = new HashSet<>();
        stack = new ArrayList<>();
        out = new ArrayList<>();

        id = 0;
        countSCC = 0;
        for(int i = 0; i < n; i++){
            int nodeValue = graph.get(i).getValue();
            ids.put(nodeValue, UNVISITED);
        }

        // Chamando a DFS para cada vértice  
        for(int i = 0; i < n; i++){
            int nodeValue = graph.get(i).getValue();
            if(ids.get(nodeValue) == UNVISITED)
                dfs(graph.get(i));
        }

        return out;
    }

    private void dfs(Node u){
        // Como é a primeira vez que u é visitado, atualizamos seu valor nas variáveis auxiliares
        stack.add(u.getValue());
        onStack.add(u.getValue());
        ids.put(u.getValue(), id);
        low.put(u.getValue(), id);
        id++;
        
        // Visitar todos os vizinho e manter o menor valor de id
        // para entre os nós que podem ser visitados partindo do nó atual
        for(Node v : u.getConnections()){
            if (ids.get(v.getValue()) == UNVISITED) {
                dfs(v);
                low.put(u.getValue(), Math.min(low.get(u.getValue()), low.get(v.getValue())));
            } 
            else if (onStack.contains(v.getValue())) {
                low.put(u.getValue(), Math.min(low.get(u.getValue()), low.get(v.getValue())));
            }
        }

        // Após minimizar o valor de id atual e visitar todos os vizinho 'u'
        // verificamos se estamos em um scc, esvaziamos o dado stack até voltarmos ao início do scc
        if(ids.get(u.getValue()) == low.get(u.getValue())){
            ArrayList<Integer> component = new ArrayList<>();

            while (true) {
                int node = stack.remove(stack.size() - 1);
                onStack.remove(node);
                component.add(node);

                if (node == u.getValue()) break;
            }
            
            out.add(component);
            countSCC++;
        }
    }       
}