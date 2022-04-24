import { Injectable } from '@nestjs/common';
import {
  Repository,
  BaseEntity,
  SaveOptions,
  DeepPartial,
  FindOptionsUtils,
  FindManyOptions,
} from 'typeorm';

export interface PaginateOptions<Entity = any> extends FindManyOptions<Entity> {
  page?: number;
  search?: string;
  offset?: number;
  isActive?: boolean;
}

@Injectable()
export class CrudService<T extends BaseEntity> {
  constructor(private readonly genericRepository: Repository<T>) {}

  async paginate(options: PaginateOptions) {
    const { page, offset } = {
      page: Number(options.page ? options.page : 1),
      offset: Number(options.offset ? options.offset : 25),
    };

    const end = page * offset;
    const start = end - offset;

    const [rows, count] = await this.genericRepository.findAndCount({
      ...(options as any),
      ...(options.offset && { take: options.offset * 1 }),
      skip: start,
    });

    const total = count;
    const totalPages = Math.ceil(total / offset);
    const next = page + 1 <= totalPages ? page + 1 : null;
    const prev = page - 1 >= 1 ? page - 1 : null;

    return {
      total,
      page,
      totalPages,
      items: rows,
      next,
      prev,
    };
  }

  async findAll(options: FindOptionsUtils = {}): Promise<T[]> {
    const data = await this.genericRepository.find(options);
    return data;
  }

  async findOne(options: FindOptionsUtils): Promise<T> {
    const data = await this.genericRepository.findOne(options);
    return data;
  }

  async findOrCreate<E extends DeepPartial<T>>(
    entity: E,
    options: FindOptionsUtils,
  ): Promise<T> {
    const data = await this.genericRepository.findOne(options);
    if (!data) {
      return this.genericRepository.save(entity);
    }
    return data;
  }

  async create<E extends DeepPartial<T>>(
    entity: E,
    options: SaveOptions = {},
  ): Promise<T> {
    return await this.genericRepository.create(entity).save(options);
  }

  async createMany<E extends DeepPartial<T>>(
    entities: E[],
    options: SaveOptions = {},
  ): Promise<T[]> {
    return await this.genericRepository.save(entities, options);
  }

  async updateOrCreate<E extends DeepPartial<T>>(
    entity: E,
    options: FindOptionsUtils,
  ): Promise<T> {
    const property = await this.genericRepository.findOne(options);
    if (property) {
      return this.genericRepository.save({
        ...property,
        ...entity,
      });
    } else {
      return await this.genericRepository.create(entity).save(options);
    }
  }

  async update<E extends DeepPartial<T>>(
    entity: E,
    options: FindOptionsUtils,
  ): Promise<T> {
    const property = await this.genericRepository.findOne(options);
    if (property) {
      return this.genericRepository.save({
        ...property,
        ...entity,
      });
    }
    return null;
  }

  async delete(options: FindOptionsUtils): Promise<T> {
    const data: any = await this.findOne(options);
    data && (await data.remove());
    return data;
  }

  async deleteAll(options: FindOptionsUtils): Promise<T> {
    const data: any = await this.findAll(options);
    data &&
      data.forEach(async (element: { remove: () => any }) => {
        await element.remove();
      });

    return data;
  }

  async softDelete(options: FindOptionsUtils): Promise<T> {
    const data: any = await this.findOne(options);
    data && (await data.softRemove());
    return data;
  }

  async softDeleteAll(options: FindOptionsUtils): Promise<T> {
    const data: any = await this.findAll(options);
    data &&
      data.forEach(async (element: { softRemove: () => any }) => {
        await element.softRemove();
      });

    return data;
  }
}
