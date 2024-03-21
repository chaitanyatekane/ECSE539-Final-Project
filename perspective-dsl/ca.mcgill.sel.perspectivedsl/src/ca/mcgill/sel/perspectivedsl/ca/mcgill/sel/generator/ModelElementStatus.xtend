package ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.generator

import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Perspective

class ModelElementStatus {
	
	def static compileElementStatus(Perspective perspective) {
		'''
		package ca.mcgill.sel.perspective.«perspective.name.toLowerCase.replaceAll("\\s", "")»;
		
		import java.util.ArrayList;
		import java.util.Collection;
		import java.util.HashMap;
		import java.util.List;
		import java.util.Map;
		
		import org.eclipse.emf.ecore.EClassifier;
		import org.eclipse.emf.ecore.EObject;
		import org.eclipse.emf.ecore.util.EcoreUtil;
		
		public class ModelElementStatus {
		
			public static ModelElementStatus INSTANCE = new ModelElementStatus();
			/**
			 * A list to contain all the existing afterElements before 
			 * the create action is called.
			 */
			private Collection<EObject> beforeElements;
			
			/**
			 * A map which contains other existing elements per language elements of interest.
			 */
			private Map<EObject, Collection<EObject>> before;
			
			/**
			 * A list to contain all the afterElements, including the new element(s).
			 */
			private Collection<EObject> afterElements = new ArrayList<EObject>();
			
			/**
			 * A map which contains other existing elements per language elements of interest,
			 * including new elements.
			 */
			private Map<EObject, Collection<EObject>> after;
			
			private ModelElementStatus() {
				beforeElements = new ArrayList<EObject>();
				before = new HashMap<EObject, Collection<EObject>>();
				after = new HashMap<EObject, Collection<EObject>>();
			}
			
			/**
			 * Adds all the existing model elements of the language element in question to
			 * a list, which helps to retrieve new element(s) after calling the
			 * language create action. Typically, this method is called before calling
			 * the language create action.
			 * @param owner - the container of the existing model elements.
			 * @param metaclass - the metaclass of the model elements.
			 */
			public void setMainExistingElements(EObject owner, EObject metaclass) {
				beforeElements.clear();
				beforeElements = EcoreUtil.getObjectsByType(owner.eContents(), (EClassifier) metaclass);
			}
			
			public void setOtherExistingElements(EObject owner, List<EObject> affectedLanguageElements) {
				before.clear();
				Collection<EObject> existingElements = new ArrayList<EObject>();
		
				// add other existing elements of the concerned language elements.
				for (EObject le : affectedLanguageElements) {
					EObject rootElement = EcoreUtil.getRootContainer(owner, true);
					if (rootElement == null) {
						existingElements = EcoreUtil.getObjectsByType(owner.eContents(), (EClassifier) le);
					} else {
						existingElements = EcoreUtil.getObjectsByType(rootElement.eContents(), (EClassifier) le);
					}
					before.put(le, existingElements);
				}
			}
			
			/**
			 * This method retrieves new element(s) after calling a language
			 * create action.
			 * @param owner - the container of the new elements.
			 * @return the new element.
			 */
			public EObject getNewElement(EObject owner, EObject metaclass) {
				afterElements = EcoreUtil.getObjectsByType(owner.eContents(), (EClassifier) metaclass);
				afterElements.removeAll(beforeElements);
				EObject newElement = afterElements.iterator().next();
				
				return newElement;
			}
			
			/**
			 * Returns new elements for each affected language element of interest
			 * @param owner - the container of the new primary element.
			 * @param affectedLanguageElements - 
			 * @return
			 */
			public Map<EObject, Collection<EObject>> getOtherNewElements(EObject owner, List<EObject> affectedLanguageElements) {
				after.clear();
				Collection<EObject> existingElements = new ArrayList<EObject>();
				for (EObject le : affectedLanguageElements) {
					EObject rootElement = EcoreUtil.getRootContainer(owner, true);
					if (rootElement == null) {
						existingElements = EcoreUtil.getObjectsByType(owner.eContents(), (EClassifier) le);
					} else {
						existingElements = EcoreUtil.getObjectsByType(rootElement.eContents(), (EClassifier) le);
					}
					existingElements.removeAll(before.get(le));
					after.put(le, existingElements);
				}
				
				return after;
			}
		}
		
		'''
	}
}