import { relationalStore } from '@kit.ArkData';
import { Space, SpaceInput, SPACE_TABLE_NAME } from '../model/SpaceModel';
import { Database } from './Database';

export class SpaceRepository {
  private db: Database = Database.getInstance();

  async insert(space: SpaceInput): Promise<number> {
    const store = this.db.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'name': space.name,
      'parentId': space.parentId,
      'level': space.level,
      'icon': space.icon,
      'image': space.image,
      'markerX': space.markerX,
      'markerY': space.markerY,
      'markerColor': space.markerColor,
    };
    const rowId: number = await store.insert(SPACE_TABLE_NAME, valueBucket);
    console.info(`SpaceRepository.insert name="${space.name}" parentId=${space.parentId} level=${space.level} rowId=${rowId}`);
    return rowId;
  }

  async getByParent(parentId: number): Promise<Space[]> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(SPACE_TABLE_NAME);
    predicates.equalTo('parentId', parentId);
    const resultSet = await store.query(predicates, [
      'id',
      'name',
      'parentId',
      'level',
      'icon',
      'image',
      'markerX',
      'markerY',
      'markerColor'
    ]);
    const spaces: Space[] = [];
    while (resultSet.goToNextRow()) {
      spaces.push({
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        parentId: resultSet.getLong(resultSet.getColumnIndex('parentId')),
        level: resultSet.getLong(resultSet.getColumnIndex('level')),
        icon: resultSet.getString(resultSet.getColumnIndex('icon')),
        image: resultSet.getString(resultSet.getColumnIndex('image')),
        markerX: resultSet.getDouble(resultSet.getColumnIndex('markerX')),
        markerY: resultSet.getDouble(resultSet.getColumnIndex('markerY')),
        markerColor: resultSet.getString(resultSet.getColumnIndex('markerColor')),
      });
    }
    resultSet.close();
    console.info(`SpaceRepository.getByParent parentId=${parentId} count=${spaces.length}`);
    return spaces;
  }

  async getById(id: number): Promise<Space | null> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(SPACE_TABLE_NAME);
    predicates.equalTo('id', id);
    const resultSet = await store.query(predicates, [
      'id',
      'name',
      'parentId',
      'level',
      'icon',
      'image',
      'markerX',
      'markerY',
      'markerColor'
    ]);
    let space: Space | null = null;
    if (resultSet.goToNextRow()) {
      space = {
        id: resultSet.getLong(resultSet.getColumnIndex('id')),
        name: resultSet.getString(resultSet.getColumnIndex('name')),
        parentId: resultSet.getLong(resultSet.getColumnIndex('parentId')),
        level: resultSet.getLong(resultSet.getColumnIndex('level')),
        icon: resultSet.getString(resultSet.getColumnIndex('icon')),
        image: resultSet.getString(resultSet.getColumnIndex('image')),
        markerX: resultSet.getDouble(resultSet.getColumnIndex('markerX')),
        markerY: resultSet.getDouble(resultSet.getColumnIndex('markerY')),
        markerColor: resultSet.getString(resultSet.getColumnIndex('markerColor')),
      };
    }
    resultSet.close();
    return space;
  }

  async delete(id: number): Promise<number> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(SPACE_TABLE_NAME);
    predicates.equalTo('id', id);
    return await store.delete(predicates);
  }

  async deleteByParent(parentId: number): Promise<number> {
    const store = this.db.getStore();
    const predicates = new relationalStore.RdbPredicates(SPACE_TABLE_NAME);
    predicates.equalTo('parentId', parentId);
    return await store.delete(predicates);
  }

  async updateImage(id: number, image: string): Promise<number> {
    const store = this.db.getStore();
    const valueBucket: relationalStore.ValuesBucket = {
      'image': image,
    };
    const predicates = new relationalStore.RdbPredicates(SPACE_TABLE_NAME);
    predicates.equalTo('id', id);
    return await store.update(valueBucket, predicates);
  }
}
