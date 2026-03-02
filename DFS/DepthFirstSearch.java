import java.util.*;

public class DepthFirstSearch {

	public DepthFirstSearch(){}

	public void iterativeDfs(Node inicialNode){
		Deque<Node> stack = new LinkedList<>();
		stack.push(inicialNode);

		while(!stack.isEmpty()){
			Node current = stack.pop();
			
			if (!current.isVisited()){
				current.setVisited(true);
				
				System.out.println(current.value);	

				for (Node node : current.getNeighbors()){
					stack.push(node);
				}
			}
		}
	}

	

	static class Node{

		private int value;
		private boolean visited;
		private List<Node> neighbors;

		
		public Node (int value){
			this.value = value;
			this.neighbors = new ArrayList<>();
		}

		public boolean isVisited(){
			return visited;
		}	
		
		public void setNeighbors(List<Node> neighbors){
			this.neighbors = neighbors;
		}
		public List<Node> getNeighbors(){
			return this.neighbors;
		}	

		public void setVisited(boolean state){
			this.visited = state;
		}
	}

}
