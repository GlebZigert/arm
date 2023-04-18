#ifndef PREVIEWCONTAINERACCESSER_H
#define PREVIEWCONTAINERACCESSER_H
#include "previewcontainer.h"

class PreviewContainerAccesser
{
public:
    PreviewContainerAccesser();

    static QSharedPointer<PreviewContainer> get();

private:
   static QSharedPointer<PreviewContainer> container;
};

#endif // PREVIEWCONTAINERACCESSER_H
