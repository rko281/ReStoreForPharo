Class {
	#name : #SSWODBCForwardOnlyResultSet,
	#superclass : #ODBCForwardOnlyResultSet,
	#category : #'SSW ReStore ODBC'
}

{ #category : #constants }
SSWODBCForwardOnlyResultSet >> bufferClass [
	"Private - Answer the buffer class to use for DBResultSets (e.g. DBBoundRow for bound buffers 
	where memory is allocated and bound using SQLBindCol, or DBUnboundRow for unbound buffers 
	which are retrieved individually)."

	^SSWODBCBoundBuffer
]

{ #category : #accessing }
SSWODBCForwardOnlyResultSet >> readStream [

	^SSWDBForwardOnlyReadStream on: self
]

{ #category : #accessing }
SSWODBCForwardOnlyResultSet >> size [

	"Return nil if not known"

	| numRows |

	numRows := self numRows.

	"Normally -1 (or sometimes less) indicates unknown. However SQLite (at least) returns zero, so err on the side of caution"
	^numRows <= 0
		ifTrue: [nil]
		ifFalse: [numRows]
]
