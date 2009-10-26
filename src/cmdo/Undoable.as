package cmdo {
	
	/**
	 * An undoable is a piece of code that can be undone and optionally redone
	 * again at some later time.
	 */
	public interface Undoable {
		
		function undo( ) : void ;
		
		function redo( ) : void ;
		
	}
	 
}
