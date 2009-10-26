package cmdo {

	/**
	 * An undo context is a group of undoables that can be undone or redone as
	 * if they were one.
	 */
	internal class UndoContext implements Undoable {

		private var undoStack : Array;
		private var redoStack : Array;
		
		
		internal function get canUndo( ) : Boolean {
			return undoStack.length > 0;
		}
		
		internal function get canRedo( ) : Boolean {
			return redoStack.length > 0;
		}
				

		public function UndoContext( ) {
			undoStack = [ ];
			redoStack = [ ];
		}
		
		internal function addUndoable( undoable : Undoable ) : void {
			undoStack.push(undoable);

			clearRedoHistory();
		}
		
		internal function clearRedoHistory( ) : void {
			redoStack = [ ];
		}
		
		internal function undoOnce( ) : void {
			if ( canUndo ) {
				var undoable : Undoable = undoStack.pop();
			
				undoable.undo();
			
				redoStack.push(undoable);
			}
		}
		
		internal function redoOnce( ) : void {
			if ( canRedo ) {
				var undoable : Undoable = redoStack.pop();

				undoable.redo();
			
				undoStack.push(undoable);
			}
		}
		
		public function undo( ) : void {
			while ( canUndo ) {
				undoOnce();
			}
		}
		
		public function redo( ) : void {
			while ( canRedo ) {
				redoOnce();
			}
		}

	}

}