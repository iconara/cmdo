package cmdo {

	import flash.events.Event;
	import flash.events.EventDispatcher;
	

	/**
	 * UndoManager keeps track of undoables and undo contexts and provides the
	 * API for working with them in a controlled manner.
	 * 
	 * To make an action undoable, encapsulate the action in an object whose
	 * class implements the Undoable interface. Make it perform the action and
	 * then hand it over to an instance of UndoManager using the #addUndoable
	 * method. Once UndoManager is managing the object you can step backwards
	 * in the undo history using #undo, step forwards using #redo, check if undo
	 * is possible with #canUndo and if redo is possible with #canRedo.
	 * 
	 * Dispatches the event "undoChanged" whenever the undo history changes.
	 */
	[Event("undoChanged")]
	public class UndoManager extends EventDispatcher {

		private var currentContext : UndoContext;
		
		private var contexts : Array;
		
		
		/**
		 * Returns true if there is an undoable that can be undone. The only
		 * time this method returns false is if there are no undoables in the
		 * undo history, if all undoables have been undone, or if #redo was just
		 * called (see #redo for more info on that).
		 */
		[Bindable(event="undoChanged")]
		public function get canUndo( ) : Boolean {
			return currentContext.canUndo;
		}
		
		/**
		 * Returns true if there is an undoable that can be redone.
		 */
		[Bindable(event="undoChanged")]
		public function get canRedo( ) : Boolean {
			return currentContext.canRedo;
		}
		

		public function UndoManager( ) {
			contexts = [ ];

			currentContext = new UndoContext();
		}
		
		private function dispatchUndoChanged( ) : void {
			dispatchEvent(new Event("undoChanged"));
		}
		
		/**
		 * Adds an undoable to be managed by this undo manager. The undo is
		 * placed at the top of the undo history and the next call to #undo
		 * will undo it. As a side effect of adding an undoable any undoables
		 * that have been undone (and then not redone) are removed from the undo
		 * history, since the history would otherwise be inconsistent.
		 */
		public function addUndoable( undoable : Undoable ) : void {
			currentContext.addUndoable(undoable);

			dispatchUndoChanged();
		}
		
		/**
		 * Puts the current undo context aside and enters a new undo context.
		 * Calling #exitContext will put the new context in the undo history of
		 * the previous context.
		 * 
		 * An undo context can be though of as a group of undoables that can be
		 * undone all at once. By entering a context you start collecting the
		 * undoables that should be part of the group, and by exiting you close
		 * the group. When the context is closed it's put in the undo history of
		 * the context that was previously opened. While the context is open
		 * undo and redo work just as normal, any undoables added can be undone
		 * simply by calling #undo -- but if you undo past where the context was
		 * started the context will be exited.
		 * 
		 * Undo contexts are useful for certain situations. Say that you have a
		 * complex dialog where you want all changes to be individually undoable
		 * as long as the dialog is open, but once the dialog has been closed
		 * you want undo to undo all the changes in one go. By entering a new
		 * undo context when the dialog is opened and exiting it when it is
		 * closed you can undo actions within the dialog as long as it's open,
		 * and then undo all the actions performed within the dialog at once
		 * when the dialog is closed.
		 */
		public function enterContext( ) : void {
			contexts.push(currentContext);
			
			currentContext = new UndoContext();
		}
		
		/**
		 * Exits the current context and enters the previous. This method will
		 * throw an ArgumentError if the current context is the root context.
		 */
		public function exitContext( ) : void {
			var previousContext : UndoContext = currentContext;
			
			if ( contexts.length > 1 ) {
				previousContext.clearRedoHistory();
				
				currentContext = contexts.pop();
			
				addUndoable(previousContext);
			} else {
				throw new ArgumentError("Cannot exit root context");
			}
		}
		
		/**
		 * Exits the current context without closing it and putting it on the
		 * undo history. All undoables added since #enterContext was last called
		 * will be discarded.
		 */
		public function discardContext( ) : void {
			currentContext = contexts.pop();
			
			dispatchUndoChanged();
		}
		
		/**
		 * Undo the undoable at the top of the undo history -- the most recently
		 * added undoable that hasn't already been undone. If the last undoable
		 * belongs to the previous undo context the current context will be
		 * exited first. If there is no undoable that can be undone this method
		 * does nothing.
		 */
		public function undo( ) : void {
			if ( canUndo ) {
				currentContext.undoOnce();
			
				dispatchUndoChanged();
			} else if ( contexts.length > 1 ) {
				exitContext();
				
				undo();
				undo();
			}
		}
		
		/**
		 * Redo the most recently undoable that was undone. If there is no such
		 * undoable this method will do nothing.
		 */
		public function redo( ) : void {
			if ( canRedo ) {
				currentContext.redoOnce();
			
				dispatchUndoChanged();
			}
		}
		
	}
 
}