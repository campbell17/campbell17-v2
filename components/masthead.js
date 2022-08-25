import styles from './masthead.module.scss'

export default function Masthead({title, subtitle}) {
  return (
    <section className={styles.masthead}>
      <h1 className={styles.title}>{title}</h1>
      <p className="soft">{subtitle}</p>
    </section>
  )
}