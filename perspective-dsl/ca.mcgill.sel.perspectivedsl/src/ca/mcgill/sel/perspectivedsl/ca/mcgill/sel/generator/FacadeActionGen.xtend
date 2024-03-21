package ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.generator

import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.BooleanType
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Language
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Perspective
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.RedefinedCreateAction
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.RedefinedDeleteAction

class FacadeActionGen {
	
	var static count = 0;

    private def static void resetCounter() {
       count = 0;
    }

   private def static void counter() {
       count++;
   }
	
	def static compileFacadeActions(Perspective perspective, Language language) {
		'''
		package ca.mcgill.sel.perspective.«perspective.name.toLowerCase.replaceAll("\\s", "")»;
		
		import java.util.ArrayList;
		import java.util.Collection;
		import java.util.HashMap;
		import java.util.List;
		import java.util.Map;
		
		import org.eclipse.emf.ecore.EObject;
		
		import ca.mcgill.sel.core.*;
		import ca.mcgill.sel.core.perspective.COREPerspectiveUtil;
		import ca.mcgill.sel.ram.ui.utils.BasicActionsUtils;
		import org.eclipse.emf.ecore.util.EcoreUtil;
		
		import «language.rootPackage».*;
		«FOR p : language.otherPackages»
			import «p.otherPackage»;
		«ENDFOR»
		
		public class «language.name»FacadeAction {
			«FOR action : language.actions»
				«IF action instanceof RedefinedCreateAction»
					«var createAction = action as RedefinedCreateAction»
					«var facadeAction = createAction.createFacadeAction»
					«resetCounter»
					
«««					The main facade action
						public static EObject createOtherElementsFor«action.languageElementName»(COREPerspective perspective, CORELanguageElementMapping mappingType, EObject otherLE, String otherRoleName, COREScene scene, 
								EObject owner, «action.typeParameters») {
							EObject newElement = null;
							Object primitiveAttribute = null;
							«FOR facadeCall : facadeAction.facadeCalls»
								«IF count === 0»
									if (otherLE.equals(«facadeCall.languageElement»)) {
										«FOR c : facadeCall.constraints»
											primitiveAttribute = «c.attributeName»;
											if (isPrimitiveType(primitiveAttribute.getClass())) {
												if (!(«c.attributeName» == «c.value»)) {
													return null;	
												} 		 
											} else {
												if (!(«c.attributeName».equals(«c.value»))) {
													return null;	
												}
											}
										«ENDFOR»
										«FOR m : facadeCall.mappings»
											«m.mapping»;
										«ENDFOR»
										newElement = «facadeCall.methodCall»;
										
										«IF perspective.saveModel !== null»
											«perspective.saveModel»;
										«ENDIF»
									}
								«ENDIF»
								«IF count > 0»
									else if (otherLE.equals(«facadeCall.languageElement»)) {
										«FOR c : facadeCall.constraints»
											primitiveAttribute = «c.attributeName»;
											if (isPrimitiveType(primitiveAttribute.getClass())) {
												if (!(«c.attributeName» == «c.value»)) {
													return null;	
												} 		 
											} else {
												if (!(«c.attributeName».equals(«c.value»))) {
													return null;	
												}
											}
										«ENDFOR»
										«FOR m : facadeCall.mappings»
											«m.mapping»;
										«ENDFOR»
										newElement = «facadeCall.methodCall»;
						
										«IF perspective.saveModel !== null»
											«perspective.saveModel»;
										«ENDIF»
									}
								«ENDIF»
								«counter»
							«ENDFOR»
							
							return newElement;						
						}
					
«««					The main create facade action
					«IF action.rootElement === BooleanType.FALSE»
						public static EObject «action.name»(COREPerspective perspective, COREScene scene, String currentRole, 
							EObject owner, «action.typeParameters») {
							
							EObject newElement = null;
						
							List<EObject> createSecondaryEffects = new ArrayList<EObject>();
							«FOR createEffect : action.createEffects»
								createSecondaryEffects.add(«createEffect.languageElement»);
							«ENDFOR»
								
							// record existing elements.
							ModelElementStatus.INSTANCE.setMainExistingElements(owner, «action.languageElement»);
							ModelElementStatus.INSTANCE.setOtherExistingElements(owner, createSecondaryEffects);
								
							// primary language action to create a new element
							«action.methodCall»;
							
							// retrieve the new element
							newElement = ModelElementStatus.INSTANCE.getNewElement(owner, «action.languageElement»);
								
							// get other new elements for each language element
							Map<EObject, Collection<EObject>> a = ModelElementStatus.INSTANCE.getOtherNewElements(owner, createSecondaryEffects);
							Map<EObject, Collection<EObject>> after = new HashMap<EObject, Collection<EObject>>(a);
	
							«IF action.createEffects.size > 0» 	
								«action.name»SecondaryEffects(perspective, scene, currentRole, after, owner, 
									«action.methodParameter»);
							«ENDIF»
						
							return newElement;
														
						}
					«ENDIF»
«««				Delete facade actions
				«ELSEIF action instanceof RedefinedDeleteAction»
				
					«var deleteAction = action as RedefinedDeleteAction»
					«var facadeAction = deleteAction.deleteFacadeAction»
					«resetCounter»
					public static void deleteOtherElementsFor«action.languageElementName»(COREPerspective perspective, COREScene scene, String otherRoleName, EObject otherElement) {
						«FOR facadeCall : facadeAction.facadeCalls»
							«IF count === 0»
								if (otherElement.eClass().equals(«facadeCall.languageElement»)) {
									«facadeCall.methodCall»;
								}
							«ENDIF»
							«IF count > 0»
								else if (otherElement.eClass().equals(«facadeCall.languageElement»)) {
									«facadeCall.methodCall»;
								}
							«ENDIF»
							«counter»
						«ENDFOR»						
					}
					
«««					The main delete facade action
					public static void «action.name»(COREPerspective perspective, COREScene scene, String currentRole, «action.typeParameters») {

						«action.methodCall»;
							
						«IF action.deleteEffects.size > 0»
							List<EObject> deleteSecondaryEffects = new ArrayList<EObject>();
							«FOR deleteEffect : action.deleteEffects»
								deleteSecondaryEffects.add(«deleteEffect.element»);
							«ENDFOR»
							«action.name»SecondaryEffects(perspective, scene, currentRole, deleteSecondaryEffects);
						«ENDIF»
					}
			
				«ENDIF»
				
«««				action effects
				«resetCounter»
«««				Create effects
				«IF action instanceof RedefinedCreateAction»
					«IF action.createEffects.size > 0» 	
						private static void «action.name»SecondaryEffects(COREPerspective perspective, COREScene scene, String currentRole, Map<EObject, Collection<EObject>> after, 
								EObject owner, «action.typeParameters») {
							for (Map.Entry<EObject, Collection<EObject>> e : after.entrySet()) {
								Collection<EObject> newElements = e.getValue();
								for (EObject newElement : newElements) {
									«FOR createEffect : action.createEffects»
										«IF count === 0»
											if (newElement.eClass().equals(«createEffect.languageElement»)) {
												«FOR m : createEffect.mappings»
													«m.mapping»;
												«ENDFOR»
															
												// Call the respective redefined recursive method
												«createEffect.methodCall»;
											}
										«ENDIF»
										«IF count > 0»
											else if (newElement.eClass().equals(«createEffect.languageElement»)) {
												«FOR m : createEffect.mappings»
													«m.mapping»;
												«ENDFOR»
													
												// Call the respective redefined recursive method
												«createEffect.methodCall»;
												}
										«ENDIF»
										«counter»
									«ENDFOR»
								}
							}
						}
					«ENDIF»
					
					«resetCounter»
	«««				Delete effects
					«IF action.deleteEffects.size > 0»
						private static void «action.name»SecondaryEffects(COREPerspective perspective, COREScene scene, String currentRole,
									List<EObject> deleteSecondaryEffects) {
							for (EObject deletedElement : deleteSecondaryEffects) {
									«FOR deleteEffect : action.deleteEffects»
										«IF count === 0»
											if (deletedElement.eClass().equals(«deleteEffect.languageElement»)) {
												«FOR m : deleteEffect.mappings»
													«m.mapping»;
												«ENDFOR»
															
												// Call the respective redefined recursive method
												«deleteEffect.methodCall»;
											}
										«ENDIF»
										«IF count > 0»
											else if (deletedElement.eClass().equals(«deleteEffect.languageElement»)) {
												«FOR m : deleteEffect.mappings»
													«m.mapping»;
												«ENDFOR»
													
												// Call the respective redefined recursive method
												«deleteEffect.methodCall»;
												}
										«ENDIF»
										«counter»
									«ENDFOR»
								}
									
						}
					«ENDIF»
				«ELSEIF action instanceof RedefinedDeleteAction»
					«IF action.createEffects.size > 0» 	
						private static void «action.name»SecondaryEffects(COREPerspective perspective, COREScene scene, String currentRole, Map<EObject, Collection<EObject>> after, 
								«action.typeParameters») {
							for (Map.Entry<EObject, Collection<EObject>> e : after.entrySet()) {
								Collection<EObject> newElements = e.getValue();
								for (EObject newElement : newElements) {
									«FOR createEffect : action.createEffects»
										«IF count === 0»
											if (newElement.eClass().equals(«createEffect.languageElement»)) {
												«FOR m : createEffect.mappings»
													«m.mapping»;
												«ENDFOR»
															
												// Call the respective redefined recursive method
												«createEffect.methodCall»;
											}
										«ENDIF»
										«IF count > 0»
											else if (newElement.eClass().equals(«createEffect.languageElement»)) {
												«FOR m : createEffect.mappings»
													«m.mapping»;
												«ENDFOR»
													
												// Call the respective redefined recursive method
												«createEffect.methodCall»;
												}
										«ENDIF»
										«counter»
									«ENDFOR»
								}
							}
						}
					«ENDIF»
					
					«resetCounter»
	«««				Delete effects
					«IF action.deleteEffects.size > 0»
						private static void «action.name»SecondaryEffects(COREPerspective perspective, COREScene scene, String currentRole,
									List<EObject> deleteSecondaryEffects) {
							for (EObject deletedElement : deleteSecondaryEffects) {
									«FOR deleteEffect : action.deleteEffects»
										«IF count === 0»
											if (deletedElement.eClass().equals(«deleteEffect.languageElement»)) {
												«FOR m : deleteEffect.mappings»
													«m.mapping»;
												«ENDFOR»
															
												// Call the respective redefined recursive method
												«deleteEffect.methodCall»;
											}
										«ENDIF»
										«IF count > 0»
											else if (deletedElement.eClass().equals(«deleteEffect.languageElement»)) {
												«FOR m : deleteEffect.mappings»
													«m.mapping»;
												«ENDFOR»
													
												// Call the respective redefined recursive method
												«deleteEffect.methodCall»;
												}
										«ENDIF»
										«counter»
									«ENDFOR»
								}
									
						}
					«ENDIF»
				«ENDIF»
				
			«ENDFOR»

			/**
			 * This is a helper method which retrieves the corresponding container of an
			 * element to create.
			 * @param perspective
			 * @param scene -  the scene of the models
			 * @param currentOwner
			 * @param otherRole
			 * @return the container of the element to create.
			 */
			private static EObject getOwner(COREPerspective perspective, COREScene scene, EObject currentOwner, String otherRole) {
				EObject ownerOther = null;
			
				List<COREModelElementMapping> ownerMappings = COREPerspectiveUtil.INSTANCE.getMappings(currentOwner, scene);
				outerloop: for (COREModelElementMapping mapping : ownerMappings) {
					CORELanguageElementMapping mappingType = COREPerspectiveUtil.INSTANCE.getMappingType(perspective, mapping);
					for (MappingEnd mappingEnd : mappingType.getMappingEnds()) {
						if (mappingEnd.getRoleName().equals(otherRole)) {
							ownerOther = COREPerspectiveUtil.INSTANCE.getOtherElement(mapping, currentOwner);
							break outerloop;
						}
					}
				}
			
				return ownerOther;
			}
			
			private static boolean isPrimitiveType(java.lang.Class<?> clazz) {
				return clazz.equals(Boolean.class) || 
				clazz.equals(Integer.class) ||
				clazz.equals(Character.class) ||
				clazz.equals(Byte.class) ||
				clazz.equals(Short.class) ||
				clazz.equals(Double.class) ||
				clazz.equals(Long.class) ||
				clazz.equals(Float.class);
			}
		}

		
		'''
		
	}
}