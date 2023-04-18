#include "previewcontaineraccesser.h"

QSharedPointer<PreviewContainer> PreviewContainerAccesser::container;
PreviewContainerAccesser::PreviewContainerAccesser()
{

}

QSharedPointer<PreviewContainer> PreviewContainerAccesser::get()
{

            if(!container){
                container=QSharedPointer<PreviewContainer>::create();
            }
            return container;

}
