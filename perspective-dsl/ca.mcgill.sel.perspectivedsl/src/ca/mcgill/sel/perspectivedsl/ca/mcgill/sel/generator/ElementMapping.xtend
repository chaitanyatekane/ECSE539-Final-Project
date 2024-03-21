package ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.generator

import ca.mcgill.sel.perspectivedsl.ca.mcgill.sel.perspectiveDSL.Perspective

class ElementMapping {
    
    def static compile(Perspective perspective) {
        
        '''
        package ca.mcgill.sel.perspective.«perspective.name.toLowerCase.replaceAll("\\s", "")»;
        
        import ca.mcgill.sel.core.CORELanguageElement;
        import ca.mcgill.sel.core.CORELanguageElementMapping;
        
        /**
         * This is a simple class which captures the details of a {@link CORELanguageElementMapping}, which include the mapping
         * type(i.e., the instance of the {@link CORELanguageElementMapping}, from mapped language element (e.g., Class
         * metaclass), and to mapped language element (e.g., Actor metaclass).
         * 
         * @author Hyacinth Ali
         *
         */
        public class ElementMapping {
        
            CORELanguageElementMapping mappingType;
            CORELanguageElement fromLanguageElement;
            CORELanguageElement toLanguageElement;
        
            /**
             * @return the mappingType
             */
            public CORELanguageElementMapping getMappingType() {
                return mappingType;
            }
        
            /**
             * @param mappingType the mappingType to set
             */
            public void setMappingType(CORELanguageElementMapping mappingType) {
                this.mappingType = mappingType;
            }
        
            /**
             * @return the fromLanguageElement
             */
            public CORELanguageElement getFromLanguageElement() {
                return fromLanguageElement;
            }
        
            /**
             * @param fromLanguageElement the fromLanguageElement to set
             */
            public void setFromLanguageElement(CORELanguageElement fromLanguageElement) {
                this.fromLanguageElement = fromLanguageElement;
            }
        
            /**
             * @return the toLanguageElement
             */
            public CORELanguageElement getToLanguageElement() {
                return toLanguageElement;
            }
        
            /**
             * @param toLanguageElement the toLanguageElement to set
             */
            public void setToLanguageElement(CORELanguageElement toLanguageElement) {
                this.toLanguageElement = toLanguageElement;
            }
        
        }
        
        '''
    }
}