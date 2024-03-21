package ca.mcgill.sel.languagedsl.ca.mcgill.sel.generator

import ca.mcgill.sel.languagedsl.ca.mcgill.sel.languageDSL.Language

class LanguageRegistration {
	
	var static count = 0;

    private def static void resetCounter() {
       count = 0;
    }

   private def static void counter() {
       count++;
   }

    def static compile(Language language) {
    '''
        package ca.mcgill.sel.core.language;

        import java.io.IOException;
        import org.eclipse.emf.ecore.EObject;

        import ca.mcgill.sel.commons.emf.util.AdapterFactoryRegistry;
        import ca.mcgill.sel.commons.emf.util.ResourceManager;
        import ca.mcgill.sel.core.util.CoreResourceFactoryImpl;
        import ca.mcgill.sel.core.provider.CoreItemProviderAdapterFactory;
        import ca.mcgill.sel.ram.ui.utils.ResourceUtils;
        import ca.mcgill.sel.core.util.COREModelUtil;

        import ca.mcgill.sel.core.*;

        import «language.rootPackage».*;

        public class «language.name» {

            public static void main (String[] args) {

                // Initialize ResourceManager
                ResourceManager.initialize();

                // Initialize CORE packages.
                CorePackage.eINSTANCE.eClass();

                // Register resource factories
                ResourceManager.registerExtensionFactory("core", new CoreResourceFactoryImpl());

                // Initialize adapter factories
                AdapterFactoryRegistry.INSTANCE.addAdapterFactory(CoreItemProviderAdapterFactory.class);

                ResourceUtils.loadLibraries();

                createLanguage();
            }

            /**
             * This method registers existing language (with its details) in TouchCORE.
             *
             * @author Hyacinth Ali
             * @return the new language {@link COREExternalLanguage}
             *
             * @generated
             */
            public static COREExternalLanguage createLanguage() {

            // create a language concern
            COREConcern langConcern = COREModelUtil.createConcern("«language.name»");

            COREExternalLanguage language = CoreFactory.eINSTANCE.createCOREExternalLanguage();
            language.setName("«language.name»");
            language.setNsURI("«language.nsURI»");
            language.setResourceFactory("«language.resourceFactory»");
            language.setAdapterFactory("«language.adapterFactory»");
            language.setWeaverClassName("«language.weaverClassName»");
            language.setFileExtension("«language.fileExtension»");
            language.setModelUtilClassName("«language.modelUtilClassName»");

            createLanguageElements(language);

            createLanguageActions(language);

            langConcern.getArtefacts().add(language);

            String language1FileName = "/Users/hyacinthali/workspace/TouchCORE2/touchram/ca.mcgill.sel.ram/resources/models/testlanguages/"
                     + "«language.getName()»";

             try {
                 ResourceManager.saveModel(langConcern, language1FileName.concat("." + "core"));
             } catch (IOException e) {
                 // Shouldn't happen.
                e.printStackTrace();
             }

             return language;
            }
            
            /**
             * This method creates languages for testing purposes.
             *
             * @author Hyacinth Ali
             * @return the new language {@link COREExternalLanguage}
             *
             * @generated
             */
            public static COREExternalLanguage createTestLanguage() {

            COREExternalLanguage language = CoreFactory.eINSTANCE.createCOREExternalLanguage();
            language.setName("«language.name»");
            language.setNsURI("«language.nsURI»");
            language.setResourceFactory("«language.resourceFactory»");
            language.setAdapterFactory("«language.adapterFactory»");
            language.setWeaverClassName("«language.weaverClassName»");
            language.setFileExtension("«language.fileExtension»");
            language.setModelUtilClassName("«language.modelUtilClassName»");

            createLanguageElements(language);

            createLanguageActions(language);

             return language;
            }

            private static void createLanguageElements(COREExternalLanguage language) {

                «FOR element : language.elements»
                    // create classdiagram core language element
                    «IF element.languageElement == "Class"»
                        CORELanguageElement «element.languageElement.toFirstLower»Element = createCORELanguageElement(language, «language.packageClassName».eINSTANCE.get«element.languageElement»_());
                    «ELSE»
                        CORELanguageElement «element.languageElement.toFirstLower»Element = createCORELanguageElement(language, «language.packageClassName».eINSTANCE.get«element.languageElement»());
                    «ENDIF»

                    «FOR nestedElement : element.nestedElements»
                        // create nested element
                        CORELanguageElement «element.languageElement.toFirstLower»«nestedElement.attributeName.toFirstUpper» = CoreFactory.eINSTANCE.createCORELanguageElement();
                        «element.languageElement.toFirstLower»«nestedElement.attributeName.toFirstUpper».setName("«nestedElement.attributeName»");
                        «element.languageElement.toFirstLower»«nestedElement.attributeName.toFirstUpper».setLanguageElement(«language.packageClassName».eINSTANCE.get«nestedElement.languageElement»());
                        
                        «element.languageElement.toFirstLower»Element.getNestedElements().add(«element.languageElement.toFirstLower»«nestedElement.attributeName.toFirstUpper»);
                        «element.languageElement.toFirstLower»«nestedElement.attributeName.toFirstUpper».setOwner(«element.languageElement.toFirstLower»Element);
                        
                    «ENDFOR»

                «ENDFOR»

            }

            /**
            * This method creates an instance of {@link CORELanguageElement} for a given language {@link COREExternalLanguage}
            * and its existing language element.
            * @param language - the language in question.
            * @param languageElement - the existing language element.
            * @return the new instance of {@link CORELanguageElement}
            *
            * @generated
            */
            private static CORELanguageElement createCORELanguageElement(COREExternalLanguage language,
                    EObject languageElement) {

                // create core language element
                CORELanguageElement coreLanguageElement = CoreFactory.eINSTANCE.createCORELanguageElement();
                coreLanguageElement.setLanguageElement(languageElement);
                language.getLanguageElements().add(coreLanguageElement);

                return coreLanguageElement;
            }

            /**
            * This method creates language actions, which can be manipulated by the perspectives
            * which reuse the language.
            *
            * @author Hyacinth Ali
            * @param language - the language
            *
            * @generated
            */
            private static void createLanguageActions(COREExternalLanguage language) {

                «resetCounter»
                «FOR action : language.actions»
                    «counter()»
                    CORELanguageAction lAction«count» = CoreFactory.eINSTANCE.createCORELanguageAction();
                    lAction«count».setName("«language.name».«action.metaclass».«action.methodNameAndParameters»");
                    language.getActions().add(lAction«count»);

                «ENDFOR»
            }
        }
    '''
   }
	
}