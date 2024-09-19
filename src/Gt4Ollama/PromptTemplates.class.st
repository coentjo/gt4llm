Class {
	#name : #PromptTemplates,
	#superclass : #Object,
	#category : #'Gt4Ollama-Chat'
}

{ #category : #'as yet unclassified' }
PromptTemplates class >> llmFeedbackOnPlan: aText [ 
	^ 'Please provide feedback on this plan: """',aText,'"""'
]
