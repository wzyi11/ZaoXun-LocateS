import { formBindingData, FormExtensionAbility, formInfo } from '@kit.FormKit';
import { Want } from '@kit.AbilityKit';

interface CardData {
  title: string;
  subtitle: string;
  hasActiveEvent: boolean;
}

export default class EntryFormAbility extends FormExtensionAbility {
  onAddForm(want: Want): formBindingData.FormBindingData {
    const cardData: CardData = {
      title: '智能收纳管家',
      subtitle: '打开应用查看待办清单',
      hasActiveEvent: false,
    };

    return formBindingData.createFormBindingData(cardData);
  }

  onCastToNormalForm(formId: string): void {
    console.info(`[EntryFormAbility] onCastToNormalForm, formId: ${formId}`);
  }

  onUpdateForm(formId: string): void {
    console.info(`[EntryFormAbility] onUpdateForm, formId: ${formId}`);
  }

  onFormEvent(formId: string, message: string): void {
    console.info(`[EntryFormAbility] onFormEvent, formId: ${formId}, message: ${message}`);
  }

  onRemoveForm(formId: string): void {
    console.info(`[EntryFormAbility] onRemoveForm, formId: ${formId}`);
  }

  onAcquireFormState(want: Want): formInfo.FormState {
    return formInfo.FormState.READY;
  }
}
