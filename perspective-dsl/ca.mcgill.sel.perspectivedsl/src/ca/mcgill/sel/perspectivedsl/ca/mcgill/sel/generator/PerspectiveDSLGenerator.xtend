/*
 * generated by Xtext 2.23.0
 */
package ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.generator

import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Language
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Perspective
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.PerspectiveAction
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.xtext.generator.AbstractGenerator
import org.eclipse.xtext.generator.IFileSystemAccess2
import org.eclipse.xtext.generator.IGeneratorContext
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.RedefinedCreateAction
import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.RedefinedDeleteAction

/**
 * Generates code from your model files on save.
 * 
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#code-generation
 */
class PerspectiveDSLGenerator extends AbstractGenerator {

	override void doGenerate(Resource resource, IFileSystemAccess2 fsa, IGeneratorContext context) {
		
		for (perspective : resource.allContents.toIterable.filter(Perspective)){
            fsa.generateFile(
                 "ca/mcgill/sel/perspective/"  + perspective.name.toLowerCase().replaceAll("\\s", "") + "/" + getPerspectiveName(perspective) + ".java",
                perspective.compile
                )
                
           fsa.generateFile(
                 "ca/mcgill/sel/perspective/"  + perspective.name.toLowerCase().replaceAll("\\s", "") + "/ModelElementStatus.java",
                ModelElementStatus.compileElementStatus(perspective)
                )
                
           fsa.generateFile(
                 "ca/mcgill/sel/perspective/"  + perspective.name.toLowerCase().replaceAll("\\s", "") + "/ModelFactory.java",
                ModelFactory.compileCreateModel(perspective)
                )
  
             for (Language language : perspective.languages) {
             	if (containsRedefinedAction(perspective, language)) {
             		fsa.generateFile(
                 		"ca/mcgill/sel/perspective/"  + perspective.name.toLowerCase().replaceAll("\\s", "") + "/" + getPerspectiveName(perspective) + "Redefined" + language.name + "Action.java",
                		RedefinedAction.compileActions(perspective, language)
                	)
             	}
             }
             for (Language language : perspective.languages) {
             	if (containsRedefinedAction(perspective, language)) {
             		fsa.generateFile(
                 		"ca/mcgill/sel/perspective/"  + perspective.name.toLowerCase().replaceAll("\\s", "") + "/" + language.name + "FacadeAction.java",
                		FacadeActionGen.compileFacadeActions(perspective, language)
                	)
             	}
             }
        }
        
        for (perspective : resource.allContents.toIterable.filter(Perspective)){
            fsa.generateFile(
                 "ca/mcgill/sel/perspective/"  + perspective.name.toLowerCase().replaceAll("\\s", "") + "/" + getPerspectiveName(perspective) + "Specification.java",
                PerspectiveSpecification.compile(perspective)
                )
        }
        
        for (perspective : resource.allContents.toIterable.filter(Perspective)){
            fsa.generateFile(
                 "ca/mcgill/sel/perspective/"  + perspective.name.toLowerCase().replaceAll("\\s", "") + "/" + "ElementMapping.java",
                ElementMapping.compile(perspective)
                )
        }
	}
	
	private def compile(Perspective perspective) {
		
		'''
		package ca.mcgill.sel.perspective.«perspective.name.toLowerCase.replaceAll("\\s", "")»;
		
		import java.io.IOException;
		import java.util.List;
		
		import org.eclipse.emf.common.util.URI;
		
		import ca.mcgill.sel.commons.ResourceUtil;
		import ca.mcgill.sel.commons.emf.util.AdapterFactoryRegistry;
		import ca.mcgill.sel.commons.emf.util.ResourceManager;
		import ca.mcgill.sel.core.COREArtefact;
		import ca.mcgill.sel.core.COREConcern;
		import ca.mcgill.sel.core.COREExternalLanguage;
		import ca.mcgill.sel.core.COREPerspective;
		import ca.mcgill.sel.core.CoreFactory;
		import ca.mcgill.sel.core.CorePackage;
		import ca.mcgill.sel.core.provider.CoreItemProviderAdapterFactory;
		import ca.mcgill.sel.core.util.COREModelUtil;
		import ca.mcgill.sel.core.util.CoreResourceFactoryImpl;
		import ca.mcgill.sel.ram.ui.utils.ResourceUtils;
		
		/**
		 * This is the base class for creating and then saving a perspective. To instantiate and then save
		 * the bnew poerspective, just run the class as a regular java class..
		 * 
		 * @author Hyacinth Ali
		 *
		 *@generated
		 *
		 */
		public class «getPerspectiveName(perspective)» {
		    
		 public static void main(String[] args) {
		        
		        // Initialize ResourceManager
		        ResourceManager.initialize();
		    
		        // Initialize CORE packages.
		        CorePackage.eINSTANCE.eClass();
		    
		        // Register resource factories
		        ResourceManager.registerExtensionFactory("core", new CoreResourceFactoryImpl());
		    
		        // Initialize adapter factories
		        AdapterFactoryRegistry.INSTANCE.addAdapterFactory(CoreItemProviderAdapterFactory.class);
		        
		        ResourceUtils.loadLibraries();
		       
		        // create a perspective
		        COREConcern perspectiveConcern = COREModelUtil.createConcern("«perspective.name»");
		        
		        COREPerspective perspective = CoreFactory.eINSTANCE.createCOREPerspective();
		        perspective.setName("«perspective.name»");
		        
		        //Add perspective to the concern
		        perspectiveConcern.getArtefacts().add(perspective);
		        
		
		        // Add existing external languages, if any
		        List<String> languages = ResourceUtil.getResourceListing("models/testlanguages/", ".core");
		        if (languages != null) {
		        	«FOR language : perspective.languages»
		        		for (String l : languages) {
		        			// load existing languages
		        			URI fileURI = URI.createURI(l);
		        			COREConcern languageConcern = (COREConcern) ResourceManager.loadModel(fileURI);
		        			for (COREArtefact a : languageConcern.getArtefacts()) {
		        				if (a instanceof COREExternalLanguage) {
		        					COREExternalLanguage existingLanguage = (COREExternalLanguage) a;
		        					if (existingLanguage.getName().equals("«language.name»")) {
		        						perspective.getLanguages().put("«language.roleName»", existingLanguage);
		        					} 
		        				}
		        			}
		        		}
		        	«ENDFOR»

		        }
		        
		        // initialize perspective with perspective actions and mappings
		        «getPerspectiveName(perspective)»Specification.initializePerspective(perspective);
		        
		        String fileName = "/Users/hyacinthali/workspace/TouchCORE2/touchram/ca.mcgill.sel.ram/resources/models/testperspectives/"
		           + "«getPerspectiveName(perspective)»_Perspective";
		        
		        try {
		            ResourceManager.saveModel(perspectiveConcern, fileName.concat("." + "core"));
		        } catch (IOException e) {
		            // Shouldn't happen.
		            e.printStackTrace();
		        } 
		   }
		}
		
		'''	
	}
	
	  /**
	  * This method checks if a language contains a redefined action.
	  */
	 def static boolean containsRedefinedAction(Perspective perspective, Language language) {
	 	for (PerspectiveAction pA : language.actions) {
	 		if (pA instanceof RedefinedCreateAction || pA instanceof RedefinedDeleteAction) {
	 			return true;
	 		}
	 	}
	 	return false;
	 }
	 
	 /**
	  * Returns the name of a perspective without white space.
	  */
	 def static String getPerspectiveName(Perspective perspective) {
	 	return perspective.name.replaceAll("\\s", "");
	 }
}
