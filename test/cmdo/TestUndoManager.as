package cmdo {

	import funit.framework.Assert;
	
	
	[TestFixture]
	public class TestUndoManager {
		
		private var undoManager : UndoManager;
		
		
		[SetUp]
		public function setup( ) : void {
			undoManager = new UndoManager();
		}
		
		[Test]
		public function cannotUndoInInitialState( ) : void {
			Assert.isFalse(undoManager.canUndo);
		}
		
		[Test]
		public function cannotRedoInInitialState( ) : void {
			Assert.isFalse(undoManager.canUndo);
		}

		[Test]
		public function cannotUndoAfterAddUndoable( ) : void {
			undoManager.addUndoable(new UndoableImpl());
			
			Assert.isFalse(undoManager.canRedo);
		}
		
		[Test]
		public function canUndoAfterAddUndoable( ) : void {
			undoManager.addUndoable(new UndoableImpl());
			
			Assert.isTrue(undoManager.canUndo);
		}
		
		[Test]
		public function canRedoAfterAddUndoableAndUndo( ) : void {
			undoManager.addUndoable(new UndoableImpl());
			undoManager.undo();
			
			Assert.isTrue(undoManager.canRedo);
		}
		
		[Test]
		public function addUndoableDoesntUndoOrRedoIt( ) : void {
			var undoable : UndoableImpl = new UndoableImpl();
			
			undoManager.addUndoable(undoable);
			
			Assert.isFalse(undoable.undone);
			Assert.isFalse(undoable.redone);
		}
		
		[Test]
		public function undoUndosUndoable( ) : void {
			var undoable : UndoableImpl = new UndoableImpl();
			
			undoManager.addUndoable(undoable);
			undoManager.undo();
			
			Assert.isTrue(undoable.undone);
		}
		
		[Test]
		public function redoRedosRedoable( ) : void {
			var undoable : UndoableImpl = new UndoableImpl();
			
			undoManager.addUndoable(undoable);
			undoManager.undo();
			undoManager.redo();
			
			Assert.isTrue(undoable.redone);
		}

		[Test]
		public function enterExitContext( ) : void {
			undoManager.enterContext();
			undoManager.exitContext();
		}
		
		[Test]
		public function enterDiscardContext( ) : void {
			undoManager.enterContext();
			undoManager.discardContext();
		}
		
		[Test]
		public function undoContextUndoesAllUndoableInTheContext( ) : void {
			var undoable1 : UndoableImpl = new UndoableImpl();
			var undoable2 : UndoableImpl = new UndoableImpl();
			var undoable3 : UndoableImpl = new UndoableImpl();
			
			undoManager.addUndoable(undoable1);
			undoManager.enterContext();
			undoManager.addUndoable(undoable2);
			undoManager.addUndoable(undoable3);
			undoManager.exitContext();
			undoManager.undo();
			
			Assert.isFalse(undoable1.undone);
			Assert.isTrue(undoable2.undone);
			Assert.isTrue(undoable3.undone);
		}
		
		[Test]
		public function discardContextRemovesAllUndoablesInTheContext( ) : void {
			var undoable1 : UndoableImpl = new UndoableImpl();
			var undoable2 : UndoableImpl = new UndoableImpl();
			var undoable3 : UndoableImpl = new UndoableImpl();
			
			undoManager.addUndoable(undoable1);
			undoManager.enterContext();
			undoManager.addUndoable(undoable2);
			undoManager.addUndoable(undoable3);
			undoManager.discardContext();
			undoManager.undo();
			
			Assert.isTrue(undoable1.undone);
			Assert.isFalse(undoable2.undone);
			Assert.isFalse(undoable3.undone);
		}
		
		[Test]
		public function cantUndoPastOpenContextsStart( ) : void {
			var undoable1 : UndoableImpl = new UndoableImpl();
			var undoable2 : UndoableImpl = new UndoableImpl();
			var undoable3 : UndoableImpl = new UndoableImpl();
			
			undoManager.addUndoable(undoable1);
			undoManager.enterContext();
			undoManager.addUndoable(undoable2);
			undoManager.addUndoable(undoable3);
			undoManager.undo();
			undoManager.undo();
			undoManager.undo();
			
			Assert.isFalse(undoable1.undone);
			Assert.isTrue(undoable2.undone);
			Assert.isTrue(undoable3.undone);
		}
		
		[Test]
		[ExpectedError("ArgumentError")]
		public function exitRootContextThrowsError( ) : void {
			undoManager.exitContext();
		}
		
		[Test]
		[ExpectedError("ArgumentError")]
		public function discardRootContextThrowsError( ) : void {
			undoManager.discardContext();
		}
		
	}
	
}


import cmdo.Undoable;


class UndoableImpl implements Undoable {

	public var undone : Boolean = false;
	public var redone : Boolean = false;


	public function undo( ) : void {
		undone = true;
		redone = false;
	}
	
	public function redo( ) : void {
		redone = true;
		undone = false;
	}
	
}