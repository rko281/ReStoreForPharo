Extension { #name : 'Context' }

{ #category : '*SSW ReStore for Pharo' }
Context >> sswFollowingPc [ 

	"Context>>followingPc does not exist in Pharo 10.
	Implement a cross-version implementation for ReStore"

	^self instructionStream followingPc
]

{ #category : '*SSW ReStore for Pharo' }
Context >> sswIsBlockReturn: aPC [
	^method encoderClass isBlockReturnAt: aPC in: method
]

{ #category : '*SSW ReStore for Pharo' }
Context >> sswIsPushLiteralNil: aPC [
	^ (self compiledCode at: aPC) = method encoderClass pushNilByte
]

{ #category : '*SSW ReStore for Pharo' }
Context >> sswIsPushTemp: aPC [
	^ self compiledCode encoderClass isPushTempAt: aPC in: method
]

{ #category : '*SSW ReStore for Pharo' }
Context >> sswNeighborPCWithCorrectMapping [

	"Copy of neighborPCWithCorrectMapping in Pharo 7.
	Currently needed by ReStore but dropped in Pharo 8"

	"Answer a pc inside the enclosing block or mathod that is correctly mapped to an AST node"
	"This is an ugly and temporary fix for Pharo 3. 
	Must be removed as soon as mappings are fixed"
	| neighborPC |
	neighborPC := self isDead 
		ifTrue: [ self startpc ]
		ifFalse: [ pc ].
	"There is a pushLiteral: nil bytecode for each temps in a block. 
	There is a 'pushTemp:' bytecode for each copied value of a block.
	These bytecodes are not mapped to any IR.
	We skip both"
	[ self sswIsPushLiteralNil: neighborPC ] whileTrue: [ neighborPC := neighborPC + 1 ].
	[ self sswIsPushTemp: neighborPC ] whileTrue: [ neighborPC := neighborPC + 1 ].
	"The block return ir instruction is mapped to the block instead of the sequence AST node. So we go just before it"
	(self sswIsBlockReturn: neighborPC) ifTrue: [ neighborPC := neighborPC - 1 ].
	^ neighborPC
]
