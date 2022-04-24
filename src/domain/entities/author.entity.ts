import {
  BaseEntity,
  Column,
  Entity,
  PrimaryGeneratedColumn,
} from 'typeorm';

@Entity({
  name: 'tbl_author',
})
export class Author extends BaseEntity {
  @PrimaryGeneratedColumn()
  idAuthor: number;

  @Column({ type: 'varchar', nullable: false })
  nationality: string;

  @Column({ type: 'varchar', nullable: false })
  firstName: string;

  @Column({ type: 'varchar', nullable: true })
  secondName: string;

  @Column({ type: 'varchar', nullable: false })
  lastName: string;

  @Column({ type: 'varchar', nullable: true })
  secondLastName: string;
}
