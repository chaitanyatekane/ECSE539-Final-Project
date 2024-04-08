package ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.generator

import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Perspective
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.LanguageElementMapping
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Cardinality
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Language
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.PerspectiveAction
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.PerspectiveActionType
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.RedefinedCreateAction
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.RedefinedDeleteAction
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.HiddenAction
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.CreateMapping

class PerspectiveSpecification {
	
	 def static compile(Perspective perspective) {
	 	
	 	'''
	 	
	 	package ca.mcgill.sel.perspective.«perspective.name.toLowerCase.replaceAll("\\s", "")»;
	 	
	 	import java.util.List;
	 	import org.eclipse.emf.ecore.EClass;
	 	import org.eclipse.emf.ecore.EObject;
	 	import org.eclipse.emf.ecore.EReference;
	 	
	 	
	 	import ca.mcgill.sel.core.*;
	 	import ca.mcgill.sel.core.language.*;
	 	
	 	«FOR language : perspective.languages»
	 		import «language.rootPackage».*;
	 	«ENDFOR»
	 	
	 	
	 	public class «perspective.name.replaceAll("\\s", "")»Specification {
	 	    
	 	    public static COREPerspective initializePerspective(COREPerspective perspective) {
	 	    	
	 	    	// add hidden concepts
	 	    	addPerspectiveHiddenConcepts(perspective);
	 	
	 	        // create perspective actions
	 	        createPerspectiveAction(perspective);
	 	
	 	        // create perspective mappings
	 	        createPerspectiveMappings(perspective);
	 	        
	 	        // create intra-language navigation mappings
	 	        createIntraLanguageMappings(perspective);
	 	        
	 	        return perspective;
	 	    }
	 	    
	 	    public static COREPerspective initializePerspective() {
	 	
	 			COREPerspective perspective = CoreFactory.eINSTANCE.createCOREPerspective();
	 			perspective.setName("«perspective.name»");
	 			
	 			// create external languages, if any
	 			COREExternalLanguage language = null;
	 			«FOR Language l : perspective.languages»
	 				language = «l.name».createTestLanguage();
	 				perspective.getLanguages().put("«l.roleName»", language);	
	 			«ENDFOR»
	 			
	 	        // create perspective actions
	 	        createPerspectiveAction(perspective);
	 	
	 	        // create perspective mappings
	 	        createPerspectiveMappings(perspective);
	 	
	 	        return perspective;
	 	    }
	 	    
	 	    /**
	 	     * Creates intra-language navigation mappings
	 	     * @param perspective
	 	     */
	 	    private static void createIntraLanguageMappings(COREPerspective perspective) {
	 			IntraLanguageMapping intraMapping = null;
	 			
	 			«FOR language : perspective.languages»
	 				«FOR intraMapping : language.mappings»
	 					intraMapping = createIntraLanguageMapping(perspective, «intraMapping.active», «intraMapping.closure», «intraMapping.reuse», 
	 						«intraMapping.increaseDepth», «intraMapping.changeModel», «intraMapping.from»);
	 					«FOR h : intraMapping.hops»
	 						intraMapping.getHops().add(«h.hop»);
	 					«ENDFOR»
	 					
	 				«ENDFOR»
	 			«ENDFOR»
	 			
	 			
	 		}
	 	    
	 	    /**
	 	     * Creates an instance of {@link IntraLanguageMapping}.
	 	     * @param perspective
	 	     * @param active
	 	     * @param closure
	 	     * @param reuse
	 	     * @param increaseDepth
	 	     * @param changeModel
	 	     * @param from
	 	     * @return return the new intraMapping
	 	     */
	 	    private static IntraLanguageMapping createIntraLanguageMapping(COREPerspective perspective, boolean active, boolean closure, 
	 	    		boolean reuse, boolean increaseDepth, boolean changeModel, EClass from) {
	 	    	IntraLanguageMapping intraMapping = CoreFactory.eINSTANCE.createIntraLanguageMapping();
	 	    	intraMapping.setActive(active);
	 	    	intraMapping.setClosure(closure);
	 	    	intraMapping.setReuse(reuse);
	 	    	intraMapping.setIncreaseDepth(increaseDepth);
	 	    	intraMapping.setChangeModel(changeModel);
	 	    	intraMapping.setFrom(from);
	 	
	 	    	perspective.getNavigationMappings().add(intraMapping);
	 	    	
	 	    	return intraMapping;
	 	    	
	 	    }
	 	
	 	    private static void createPerspectiveAction(COREPerspective perspective) {
	 	        // create perspective actions
	 	
	 	        COREPerspectiveAction pAction = null;
	 	        
	 	        «FOR language : perspective.languages»
	 	        
	 	        	
	 	        	«FOR action : language.actions»
	 	        		«IF action instanceof RedefinedCreateAction || action instanceof RedefinedDeleteAction»
	 	        			pAction = CoreFactory.eINSTANCE.createCORERedefineAction();
	 	        			pAction.setName("«action.name»");
	 	        			pAction.setForRole("«language.roleName»");
	 	        			perspective.getActions().add(pAction);
	 	        		«ELSEIF action instanceof HiddenAction»
	 	        			pAction = CoreFactory.eINSTANCE.createCOREHiddenAction();
	 	        			pAction.setName("«action.name»");
	 	        			pAction.setForRole("«language.roleName»");
	 	        			perspective.getActions().add(pAction);
	 	        		«ELSEIF action instanceof CreateMapping»
	 	        			pAction = CoreFactory.eINSTANCE.createCORECreateMapping();
	 	        			pAction.setName("«action.name»");
	 	        			pAction.setForRole("«language.roleName»");
	 	        			perspective.getActions().add(pAction);	 	        		
	 	        		«ENDIF»
	 	        	«ENDFOR»
	 	        	
	 	        	
	 	        	
	 	        	
	 	        «ENDFOR»
	 	       }
	 	       
	 	    private static void addPerspectiveHiddenConcepts(COREPerspective perspective){
	 	    	«FOR language : perspective.languages»
	 	    		// create empty set	        	
	 	        	// while list not empty
	 	        	// add children to list, make curr hidden, remove curr from list
	 	        	// create empty set	 
	 	        	«FOR hiddenConcept : language.hiddenConcepts»
	 	        		// add concepts to set
	 	        	«ENDFOR» 	  
	 	        	
	 	        	«FOR hiddenConcept : language.hiddenConcepts»
	 	        		 	      // add concepts to set
	 	        	«ENDFOR» 
	 	        	      	
	 	    		 	        	
	 	    	«ENDFOR»
	 	    	
	 	    	// TODO: ADD ASSOCIATION BETWEEN PERSPECTIVE AND CONCEPT
	 	    		 	        		
	 	    	// TODO: CREATE HIDDEN ACTION FOR ALL ASSOCIATED ACTIONS
	 	    	
	 	    	
	 	    		
	 	    }
	 	
	 	    private static void createPerspectiveMappings(COREPerspective perspective) {
	 	
	 	        // language element mappings 
	 	        «FOR mapping : perspective.mappings»
	 	        	«IF mapping.biDirectional»
«««	 	        		Handle mappings with bi-directional navigation specifications
		 	        	«IF mapping.nestedMappings.empty» 
	«««	 	        		creates language element mappings with nested mapping(s)
		 	        		createLanguageElementMapping(perspective, «getCardinality(mapping, true)», "«mapping.fromRoleName»", 
		 	        			«mapping.fromLanguageElement», «mapping.fromIsRootElement», «getCardinality(mapping, false)», "«mapping.toRoleName»", «mapping.toLanguageElement», «mapping.toIsRootElement»,
		 	        			«mapping.active», «mapping.isDefault», "«mapping.fromMappingEndName»", "«mapping.toMappingEndName»", true, true, true, true);
		 	        		
		 	         	«ELSE»
	«««	 	        		crates language element mappings with nested mapping(s)
		 	            	ElementMapping «mapping.name.toFirstLower»Mapping = createLanguageElementMapping(perspective, «getCardinality(mapping, true)», "«mapping.fromRoleName»", 
		 	            		«mapping.fromLanguageElement», «mapping.fromIsRootElement», «getCardinality(mapping, false)», "«mapping.toRoleName»", «mapping.toLanguageElement», «mapping.toIsRootElement»,
		 	            				 	        			«mapping.active», «mapping.isDefault», "«mapping.fromMappingEndName»", "«mapping.toMappingEndName»", true, true, true, true); 	            	    	
		 	            	 	            
		 	            	CORELanguageElementMapping «mapping.name.toFirstLower»MappingType = «mapping.name.toFirstLower»Mapping.getMappingType();
		 	            		 	            
		 	            	// get from mapped language element, i.e., the from container of the feature to be mapped.
		 	            	CORELanguageElement «mapping.name.toFirstLower»MappingFromLanguageELement = «mapping.name.toFirstLower»Mapping.getFromLanguageElement();
		 	            		 	            
		 	            	// get to mapped language element, i.e., the to container of the feature to be mapped.
		 	            	CORELanguageElement «mapping.name.toFirstLower»MappingToLanguageELement = «mapping.name.toFirstLower»Mapping.getToLanguageElement();
		 	            		 	            
		 	            	«FOR nestedMapping : mapping.nestedMappings»
		 	            		createNestedMapping(«mapping.name.toFirstLower»MappingType, «mapping.name.toFirstLower»MappingFromLanguageELement, 
		 	            	    	«mapping.name.toFirstLower»MappingToLanguageELement, "«nestedMapping.fromElementName»", "«nestedMapping.toElementName»", 
		 	            	        	"«mapping.fromRoleName»", "«mapping.toRoleName»", «nestedMapping.matchMaker»);
		 	            	«ENDFOR»
		 	            
		 	          	«ENDIF»
	 	        	«ELSEIF mapping.uniDirectional»
«««	 	        		Handle mappings with uni-directional navigation specifications
		 	        	«IF mapping.nestedMappings.empty» 
	«««	 	        		creates language element mappings with nested mapping(s)
		 	        		createLanguageElementMapping(perspective, «getCardinality(mapping, true)», "«mapping.fromRoleName»", 
		 	        			«mapping.fromLanguageElement», «mapping.fromIsRootElement», «getCardinality(mapping, false)», "«mapping.toRoleName»", «mapping.toLanguageElement», «mapping.toIsRootElement»,
		 	        			«mapping.active», «mapping.isDefault», "«mapping.fromMappingEndName»", "«mapping.toMappingEndName»", 
		 	        			«mapping.fromOrigin», «mapping.fromDestination», «mapping.toOrigin», «mapping.toDestination»);
		 	        		
		 	         	«ELSE»
	«««	 	        		crates language element mappings with nested mapping(s)
		 	            	ElementMapping «mapping.name.toFirstLower»Mapping = createLanguageElementMapping(perspective, «getCardinality(mapping, true)», "«mapping.fromRoleName»", 
		 	            		«mapping.fromLanguageElement», «mapping.fromIsRootElement», «getCardinality(mapping, false)», "«mapping.toRoleName»", «mapping.toLanguageElement», «mapping.toIsRootElement»,
		 	            				 	        			«mapping.active», «mapping.isDefault», "«mapping.fromMappingEndName»", "«mapping.toMappingEndName»", 
		 	            				 	        			«mapping.fromOrigin», «mapping.fromDestination», «mapping.toOrigin», «mapping.toDestination»);	            	    	
		 	            	 	            
		 	            	CORELanguageElementMapping «mapping.name.toFirstLower»MappingType = «mapping.name.toFirstLower»Mapping.getMappingType();
		 	            		 	            
		 	            	// get from mapped language element, i.e., the from container of the feature to be mapped.
		 	            	CORELanguageElement «mapping.name.toFirstLower»MappingFromLanguageELement = «mapping.name.toFirstLower»Mapping.getFromLanguageElement();
		 	            		 	            
		 	            	// get to mapped language element, i.e., the to container of the feature to be mapped.
		 	            	CORELanguageElement «mapping.name.toFirstLower»MappingToLanguageELement = «mapping.name.toFirstLower»Mapping.getToLanguageElement();
		 	            		 	            
		 	            	«FOR nestedMapping : mapping.nestedMappings»
		 	            		createNestedMapping(«mapping.name.toFirstLower»MappingType, «mapping.name.toFirstLower»MappingFromLanguageELement, 
		 	            	    	«mapping.name.toFirstLower»MappingToLanguageELement, "«nestedMapping.fromElementName»", "«nestedMapping.toElementName»", 
		 	            	        	"«mapping.fromRoleName»", "«mapping.toRoleName»", «nestedMapping.matchMaker»);
		 	            	«ENDFOR»
		 	            
		 	          	«ENDIF»
	 	        	«ELSE»
«««	 	        		Handle mappings without navigation specifications
		 	        	«IF mapping.nestedMappings.empty» 
	«««	 	        		creates language element mappings with nested mapping(s)
							createLanguageElementMapping(perspective, «getCardinality(mapping, true)», "«mapping.fromRoleName»", 
		 	        			 	         		«mapping.fromLanguageElement», «mapping.fromIsRootElement», 
		 	        			 	         		«getCardinality(mapping, false)», "«mapping.toRoleName»", «mapping.toLanguageElement», «mapping.toIsRootElement»);
		 	        		
		 	         	«ELSE»
	«««	 	        		crates language element mappings with nested mapping(s)
		 	            	ElementMapping «mapping.name.toFirstLower»Mapping = createLanguageElementMapping(perspective, «getCardinality(mapping, true)», "«mapping.fromRoleName»", 
		 	            		«mapping.fromLanguageElement», «mapping.fromIsRootElement», «getCardinality(mapping, false)», 
		 	            		"«mapping.toRoleName»", «mapping.toLanguageElement», «mapping.toIsRootElement»); 	            	    	
		 	            	 	            
		 	            	CORELanguageElementMapping «mapping.name.toFirstLower»MappingType = «mapping.name.toFirstLower»Mapping.getMappingType();
		 	            		 	            
		 	            	// get from mapped language element, i.e., the from container of the feature to be mapped.
		 	            	CORELanguageElement «mapping.name.toFirstLower»MappingFromLanguageELement = «mapping.name.toFirstLower»Mapping.getFromLanguageElement();
		 	            		 	            
		 	            	// get to mapped language element, i.e., the to container of the feature to be mapped.
		 	            	CORELanguageElement «mapping.name.toFirstLower»MappingToLanguageELement = «mapping.name.toFirstLower»Mapping.getToLanguageElement();
		 	            		 	            
		 	            	«FOR nestedMapping : mapping.nestedMappings»
		 	            		createNestedMapping(«mapping.name.toFirstLower»MappingType, «mapping.name.toFirstLower»MappingFromLanguageELement, 
		 	            	    	«mapping.name.toFirstLower»MappingToLanguageELement, "«nestedMapping.fromElementName»", "«nestedMapping.toElementName»", 
		 	            	        	"«mapping.fromRoleName»", "«mapping.toRoleName»", «nestedMapping.matchMaker»);
		 	            	«ENDFOR»
		 	            
		 	          	«ENDIF»
	 	        	«ENDIF»

	 	         
	 	        «ENDFOR»
	 	        
	 	    }
	 	
	 	    /**
	 	     * This method creates an instance of {@link CORELanguageElementMapping}.
	 	     * @param perspective 
	 	     * @param fromCardinality
	 	     * @param fromRoleName
	 	     * @param fromMetaclass
	 	     * @param toCardinality
	 	     * @param toRoleName
	 	     * @param toMetaclass
	 	     * @return the language element mapping.
	 	     * 
	 	     * @author Hyacinth Ali
	 	     */
	 	    private static ElementMapping createLanguageElementMapping(COREPerspective perspective,
	 	                Cardinality fromCardinality, String fromRoleName, EObject fromMetaclass, boolean fromIsRootMapping, Cardinality toCardinality, 
	 	                String toRoleName, EObject toMetaclass, boolean toIsRootMapping) {
	 	
	 	        CORELanguageElementMapping mappingType = CoreFactory.eINSTANCE.createCORELanguageElementMapping();
	 	        mappingType.setIdentifier(getNextMappingId(perspective));
	 			
	 	        // from mapping end settings
	 	        MappingEnd fromMappingEnd = CoreFactory.eINSTANCE.createMappingEnd();
	 	        fromMappingEnd.setRootMappingEnd(fromIsRootMapping);
	 	        fromMappingEnd.setCardinality(fromCardinality);
	 	        fromMappingEnd.setRoleName(fromRoleName);
	 	        COREExternalLanguage fromLanguage = (COREExternalLanguage) perspective.getLanguages().get(fromRoleName);
	 	        CORELanguageElement fromLanguageElement = getLanguageElement(fromLanguage, fromMetaclass);
	 	        fromMappingEnd.setLanguageElement(fromLanguageElement);
	 	
	 	        // to mapping end settings
	 	        MappingEnd toMappingEnd = CoreFactory.eINSTANCE.createMappingEnd();
	 	        toMappingEnd.setRootMappingEnd(toIsRootMapping);
	 	        toMappingEnd.setCardinality(toCardinality);
	 	        toMappingEnd.setRoleName(toRoleName);
	 	        COREExternalLanguage toLanguage = (COREExternalLanguage) perspective.getLanguages().get(toRoleName);
	 	        CORELanguageElement toLanguageElement =
	 	                getLanguageElement(toLanguage, toMetaclass);
	 	        toMappingEnd.setLanguageElement(toLanguageElement);
	 	
	 	        mappingType.getMappingEnds().add(fromMappingEnd);
	 	        mappingType.getMappingEnds().add(toMappingEnd);
	 	
	 	        perspective.getMappings().add(mappingType);
	 	
	 	        ElementMapping elementMapping = new ElementMapping();
	 	        elementMapping.setMappingType(mappingType);
	 	        elementMapping.setFromLanguageElement(fromLanguageElement);
	 	        elementMapping.setToLanguageElement(toLanguageElement);
	 	
	 	        return elementMapping;
	 	    }
	 	    
	 	    /**
	 	     * This method creates an instance of {@link CORELanguageElementMapping} with navigation specification.
	 	     * @param perspective 
	 	     * @param fromCardinality
	 	     * @param fromRoleName
	 	     * @param fromMetaclass
	 	     * @param toCardinality
	 	     * @param toRoleName
	 	     * @param toMetaclass
	 	     * @return the language element mapping.
	 	     * 
	 	     * @author Hyacinth Ali
	 	     */
	 	    private static ElementMapping createLanguageElementMapping(COREPerspective perspective,
	 	                Cardinality fromCardinality, String fromRoleName, EObject fromMetaclass, boolean fromIsRootMapping, Cardinality toCardinality, 
	 	                String toRoleName, EObject toMetaclass, boolean toIsRootMapping,
	 	                boolean active, boolean isDefault, String fromMappingEndName, String toMappingEndName,
	 	                boolean fromOrigin, boolean fromDestination, boolean toOrigin, boolean toDestination) {
	 	
	 			// Navigation Specification
	 	        CORELanguageElementMapping mappingType = CoreFactory.eINSTANCE.createCORELanguageElementMapping();
	 	        mappingType.setIdentifier(getNextMappingId(perspective));
	 			
	 	        // from mapping end settings
	 	        MappingEnd fromMappingEnd = CoreFactory.eINSTANCE.createMappingEnd();
	 	        fromMappingEnd.setRootMappingEnd(fromIsRootMapping);
	 	        fromMappingEnd.setCardinality(fromCardinality);
	 	        fromMappingEnd.setRoleName(fromRoleName);
	 	        COREExternalLanguage fromLanguage = (COREExternalLanguage) perspective.getLanguages().get(fromRoleName);
	 	        CORELanguageElement fromLanguageElement = getLanguageElement(fromLanguage, fromMetaclass);
	 	        fromMappingEnd.setLanguageElement(fromLanguageElement);
	 	
	 	        // to mapping end settings
	 	        MappingEnd toMappingEnd = CoreFactory.eINSTANCE.createMappingEnd();
	 	        toMappingEnd.setRootMappingEnd(toIsRootMapping);
	 	        toMappingEnd.setCardinality(toCardinality);
	 	        toMappingEnd.setRoleName(toRoleName);
	 	        COREExternalLanguage toLanguage = (COREExternalLanguage) perspective.getLanguages().get(toRoleName);
	 	        CORELanguageElement toLanguageElement =
	 	                getLanguageElement(toLanguage, toMetaclass);
	 	        toMappingEnd.setLanguageElement(toLanguageElement);
	 	
	 	        mappingType.getMappingEnds().add(fromMappingEnd);
	 	        mappingType.getMappingEnds().add(toMappingEnd);
	 	
	 	        // Navigation Specification
	 	        InterLanguageMapping navMapping = CoreFactory.eINSTANCE.createInterLanguageMapping();
	 			navMapping.setActive(active);
	 			navMapping.setDefault(isDefault);
	 			navMapping.setCoreLanguageElementMapping(mappingType);
	 			
	 			InterLanguageMappingEnd fromInterMappingEnd = CoreFactory.eINSTANCE.createInterLanguageMappingEnd();
	 			fromInterMappingEnd.setMappingEnd(fromMappingEnd);
	 			fromInterMappingEnd.setName(fromMappingEndName);
	 			fromInterMappingEnd.setOrigin(fromOrigin);
	 			fromInterMappingEnd.setDestination(fromDestination);
	 			navMapping.getInterLanguageMappingEnds().add(fromInterMappingEnd);
	 			
	 			InterLanguageMappingEnd toInterMappingEnd = CoreFactory.eINSTANCE.createInterLanguageMappingEnd();
	 			toInterMappingEnd.setMappingEnd(toMappingEnd);
	 			toInterMappingEnd.setName(toMappingEndName);
	 			toInterMappingEnd.setOrigin(toOrigin);
	 			toInterMappingEnd.setDestination(toDestination);
	 			navMapping.getInterLanguageMappingEnds().add(toInterMappingEnd);
	 	        
	 			// Add the mapping to perspective
	 	        perspective.getMappings().add(mappingType);
	 	        
	 	        // Add the navigation mapping to the perspective
	 	        perspective.getNavigationMappings().add(navMapping);
	 	
	 	        ElementMapping elementMapping = new ElementMapping();
	 	        elementMapping.setMappingType(mappingType);
	 	        elementMapping.setFromLanguageElement(fromLanguageElement);
	 	        elementMapping.setToLanguageElement(toLanguageElement);
	 	
	 	        return elementMapping;
	 	    }
	 	    
	 	
	 	    /**
	 	     * This method creates nested mapping, i.e., a language element mapping which is contained in another language 
	 	     * element mapping.
	 	     * 
	 	     * @author Hyacinth Ali
	 	     * @param mappingType - the container of the nested mapping.
	 	     * @param fromLanguageElement - from mapped language element of the mappingType
	 	     * @param toLanguageElement - to mapped language element of the mappingType
	 	     * @param fromNestedElementName - from nested language element name
	 	     * @param toNestedElementName - to nested language element name
	 	     * @param fromRoleName - the role name of the from language in the perspective.
	 	     * @param toRoleName - the role name of the to language in the perspective.
	 	     * @param matchMaker - the flag which determines if the values of the respective nested mapping language elements
	 	     * can used to find corresponding element.
	 	     */
	 	    private static void createNestedMapping(CORELanguageElementMapping mappingType,
	 	            CORELanguageElement fromLanguageElement, CORELanguageElement toLanguageElement, String fromNestedElementName, 
	 	            String toNestedElementName, String fromRoleName, String toRoleName, boolean matchMaker) {
	 	
	 	        // from nested language element, which is contained in fromLanguageElement
	 	        CORELanguageElement fromNestedElement = getNestedElement(fromLanguageElement, fromNestedElementName);
	 	        
	 	        // to nested language element, which is contained in toLanguageElement
	 	        CORELanguageElement toNestedElement = getNestedElement(toLanguageElement, toNestedElementName);
	 	
	 	        // create the nested mapping
	 	        CORELanguageElementMapping nestedElementMapping = CoreFactory.eINSTANCE.createCORELanguageElementMapping();
	 	        nestedElementMapping.setMatchMaker(matchMaker);
	 	        
	 	        MappingEnd fromNestedElementMappingEnd = CoreFactory.eINSTANCE.createMappingEnd();
	 	        fromNestedElementMappingEnd.setRoleName(fromRoleName);
	 	        fromNestedElementMappingEnd.setLanguageElement(fromNestedElement);
	 	        
	 	        MappingEnd toNestedElementMappingEnd = CoreFactory.eINSTANCE.createMappingEnd();
	 	        toNestedElementMappingEnd.setRoleName(toRoleName);
	 	        toNestedElementMappingEnd.setLanguageElement(toNestedElement);
	 	        
	 	        nestedElementMapping.getMappingEnds().add(fromNestedElementMappingEnd);
	 	        fromNestedElementMappingEnd.setType(nestedElementMapping);
	 	        nestedElementMapping.getMappingEnds().add(toNestedElementMappingEnd);
	 	        toNestedElementMappingEnd.setType(nestedElementMapping);
	 	         
	 	        mappingType.getNestedMappings().add(nestedElementMapping);
	 	    }
	 	
	 	    /**
	 	     * This method returns an instance of {@link CORELanguageElement} based on the language container and the
	 	     * referenced language element.
	 	     * 
	 	     * @param language, the container of the language element.
	 	     * @param element of the interest.
	 	     * @return the language element.
	 	     */
	 	    private static CORELanguageElement getLanguageElement(COREExternalLanguage language, EObject element) {
	 	        CORELanguageElement languageElement = null;
	 	        for (CORELanguageElement le : language.getLanguageElements()) {
	 	            if (le.getLanguageElement().equals(element)) {
	 	                languageElement = le;
	 	                break;
	 	            }
	 	        }
	 	
	 	        return languageElement;
	 	
	 	    }
	 	
	 	    /**
	 	     * This helper method returns an instance of a {@link CORELanguageElement} (most structural feature) which are 
	 	     * contained in another language element. E.g., the structural feature of the name in a class (i.e., a language 
	 	     * element).
	 	     * @param owner of the language element to be retrieved.
	 	     * @param elementName the given name for the element.
	 	     * @return the contained element.
	 	     */
	 	    private static CORELanguageElement getNestedElement(CORELanguageElement owner, String elementName) {
	 	        CORELanguageElement nestedElement = null;
	 	        for (CORELanguageElement element : owner.getNestedElements()) {
	 	            if (element.getName().equals(elementName)) {
	 	                nestedElement = element;
	 	                break;
	 	            }
	 	        }
	 	        return nestedElement;
	 	    }
	 	    
	 		private static int getNextMappingId(COREPerspective perspective) {
	 	
	 			int idNumber = 0;
	 			for (CORELanguageElementMapping lem : perspective.getMappings()) {
	 				if (lem.getIdentifier() > idNumber) {
	 					idNumber = lem.getIdentifier();
	 				}
	 			}
	 			return idNumber + 1;
	 		}
	 	}
	 	
	 	
	 	'''
	 	
	 }
	 
	 /**
	  * Gets the cardinality of a given mapping-end.
	  */
	 def static String getCardinality(LanguageElementMapping mapping, boolean isFrom) {
	     var cardinality = ''
	
	     if (isFrom) {
	         
	         switch(mapping.fromCardinality) {
            case COMPULSORY: {
                cardinality = "Cardinality.COMPULSORY"
            }
            case COMPULSORY_MULTIPLE: {
                cardinality = "Cardinality.COMPULSORY_MULTIPLE"
            }
            case OPTIONAL: {
                cardinality = "Cardinality.OPTIONAL"
            }
            case OPTIONAL_MULTIPLE: {
                cardinality = "Cardinality.OPTIONAL_MULTIPLE"
            }
             
         }
	         
	     } else {
	         
	         switch(mapping.toCardinality) {
            case COMPULSORY: {
                cardinality = "Cardinality.COMPULSORY"
            }
            case COMPULSORY_MULTIPLE: {
                cardinality = "Cardinality.COMPULSORY_MULTIPLE"
            }
            case OPTIONAL: {
                cardinality = "Cardinality.OPTIONAL"
            }
            case OPTIONAL_MULTIPLE: {
                cardinality = "Cardinality.OPTIONAL_MULTIPLE"
            }
             
          }
	         
	     }
	     
	     return cardinality
	 }
	
}
