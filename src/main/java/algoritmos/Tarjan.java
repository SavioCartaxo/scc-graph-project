package main.java.algoritmos;

import java.util.ArrayList;
import java.util.ArrayDeque;
import java.util.Arrays;
import java.util.Deque;

/**
 * Algoritmo de Tarjan para Strongly Connected Components (SCCs).
 * Complexidade: O(V + E)
 */
public class Tarjan {

    private static final int UNVISITED = -1;

    private int[] ids;          // ordem de descoberta de cada nó
    private int[] low;          // menor id acessível a partir de cada nó
    private boolean[] onStack;  // indica se o nó está atualmente na pilha
    private int[] stack;        // pilha de nós do SCC atual
    private int stackTop;

    private int id;             // contador global de descoberta
    private int[] originalValues;           // índice → valor original do nó
    private ArrayList<Node>[] adj;          // cache das adjacências
    private ArrayList<ArrayList<Integer>> out;

    public ArrayList<ArrayList<Integer>> scc(ArrayList<Node> graph) {
        final int n = graph.size();

        ids = new int[n];
        low = new int[n];
        onStack = new boolean[n];
        stack = new int[n];
        originalValues = new int[n];
        stackTop = 0;
        out = new ArrayList<>();

        Arrays.fill(ids, UNVISITED);
        id = 0;

        // Cache das adjacências e valores originais
        @SuppressWarnings("unchecked")
        ArrayList<Node>[] adjLocal = new ArrayList[n];
        for (int i = 0; i < n; i++) {
            adjLocal[i] = graph.get(i).getConnections();
            originalValues[i] = graph.get(i).getValue();
        }
        adj = adjLocal;

        // Garante que todos os nós sejam visitados, mesmo em grafos desconexos
        for (int i = 0; i < n; i++) {
            if (ids[i] == UNVISITED) dfs(i);
        }

        return out;
    }

    private void dfs(int start) {
        // Cada frame guarda [nó atual, índice do próximo vizinho a visitar]
        Deque<int[]> callStack = new ArrayDeque<>();

        // Visita o nó inicial
        ids[start] = low[start] = id++;
        stack[stackTop++] = start;
        onStack[start] = true;
        callStack.push(new int[]{start, 0});

        while (!callStack.isEmpty()) {
            int[] frame = callStack.peek();
            int u = frame[0];
            ArrayList<Node> neighbors = adj[u];

            if (frame[1] < neighbors.size()) {
                // Ainda há vizinhos a processar
                int v = neighbors.get(frame[1]++).getIdNormalizado(); // índice direto, sem mapa

                if (ids[v] == UNVISITED) {
                    // Tree-edge: empilha o vizinho e desce
                    ids[v] = low[v] = id++;
                    stack[stackTop++] = v;
                    onStack[v] = true;
                    callStack.push(new int[]{v, 0});
                } else if (onStack[v]) {
                    // Back-edge: atualiza low do nó atual
                    low[u] = Math.min(low[u], ids[v]);
                }

            } else {
                // Todos os vizinhos de u foram processados — retorno da DFS
                callStack.pop();

                // Propaga low para o pai
                if (!callStack.isEmpty()) {
                    int parent = callStack.peek()[0];
                    low[parent] = Math.min(low[parent], low[u]);
                }

                // Se u é raiz de um SCC, esvazia a pilha até u
                if (ids[u] == low[u]) {
                    ArrayList<Integer> component = new ArrayList<>();
                    while (true) {
                        int node = stack[--stackTop];
                        onStack[node] = false;
                        low[node] = ids[u];
                        component.add(originalValues[node]);
                        if (node == u) break;
                    }
                    out.add(component);
                }
            }
        }
    }
}