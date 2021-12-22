Extension { #name : #SimplePerson }

{ #category : #'*SSW ReStore Tests-Pharo' }
SimplePerson class >> compiler [

	^ super compiler options: #(- optionInlineAndOr optionInlineIfNil)
]
