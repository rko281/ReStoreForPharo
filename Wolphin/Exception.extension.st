Extension { #name : #Exception }

{ #category : #'*Wolphin' }
Exception class >> signal: message with: aTag [
		
	^self signal: message withTag: aTag
]

{ #category : #'*Wolphin' }
Exception class >> signalWith: aTag [
		
	^self signal: nil with: aTag
]
