"
ReStore
©2019 John Aspinall
https://github.com/rko281/ReStoreForDolphin
https://github.com/rko281/ReStoreForPharo
"
Class {
	#name : #SSWDBScaledDecimalWithInfo,
	#superclass : #SSWDBClassWithInfo,
	#instVars : [
		'scale',
		'precision'
	],
	#category : #'SSW ReStore Base Additions'
}

{ #category : #constants }
SSWDBScaledDecimalWithInfo >> infoClass [

	^ScaledDecimal
]

{ #category : #accessing }
SSWDBScaledDecimalWithInfo >> precision [

	"precision stores the total number of digits that should be in this pseudo-ScaledDecimal.
	precision is optional; it is used by SQL (to create tables) and not ScaledDecimal itself
	 - if omitted, a sensible fallback will be used"

	^precision
]

{ #category : #accessing }
SSWDBScaledDecimalWithInfo >> precision: anInteger [

	"precision stores the total number of digits that should be in this pseudo-ScaledDecimal.
	precision is optional; it is used by SQL (to create tables) and not ScaledDecimal itself
	 - if omitted, a sensible fallback will be used"

	precision := anInteger
]

{ #category : #accessing }
SSWDBScaledDecimalWithInfo >> scale [

	"scale stores the scale of ScaledDecimal which the receiver creates/represents"

	^scale
]

{ #category : #accessing }
SSWDBScaledDecimalWithInfo >> scale: anInteger [

	"scale stores the scale of ScaledDecimal which the receiver creates/represents"

	scale := anInteger
]
