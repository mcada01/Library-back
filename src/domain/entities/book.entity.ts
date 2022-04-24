import {
  BaseEntity,
  Column,
  Entity,
  JoinColumn,
  ManyToOne,
  PrimaryGeneratedColumn,
} from 'typeorm';
import { Author } from './author.entity';

@Entity({
  name: 'tbl_book',
})
export class Book extends BaseEntity {
  //Product> {
  @PrimaryGeneratedColumn()
  idBook: number;

  @Column({ type: 'varchar', nullable: false })
  name: string;

  @Column({ name: 'idAuthor', nullable: false })
  idAuthor: number;

  @ManyToOne(() => Author)
  @JoinColumn({ name: 'idAuthor' })
  author: Author;
}
